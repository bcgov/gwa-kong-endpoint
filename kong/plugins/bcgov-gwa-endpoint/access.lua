local utils = require "kong.tools.utils"
local cache = require "kong.tools.database_cache"
local singletons = require "kong.singletons"
local constants = require "kong.constants"
local responses = require "kong.tools.responses"

local ngx_set_header = ngx.req.set_header
local ngx_get_headers = ngx.req.get_headers
  
local _M = {}

function _M.execute(conf)
  local ok, err = doSiteminderAuthentication(conf)
  if not ok then
    return responses.send(err.status, err.message)
  end
end

local function doSiteminderAuthentication(conf)
  local headers = ngx_get_headers()
  local userguid = headers["smgov_userguid"]
  if userguid then
    local authdirname = headers["sm_authdirname"]
    local universalid = headers["sm_universalid"]
    if not (authdirname and universalid) then
      return false, {status = 403}
    else
      local customId = authdirname..'_'..userguid
      local username = authdirname..'_'..universalid
      local consumer = loadConsumer(customId, username)
      if consumer then
        setConsumer(consumer, authdirname, universalid)
      else
        return false, {status = 403}
      end
    end
  end
  return true
end

local function findConsumer(parameters)
  local dao = singletons.dao.consumers
  local consumers, err = dao:find_all(parameters)
  if err then
    return consumers, err
  else
    for _, consumer in ipairs(consumers) do
      return consumer
    end
  end
end

local function loadConsumer(customId, username)
  local dao = singletons.dao.consumers
  local consumer, err = findConsumer({ custom_id = customId })
  if err then
    return _, err
  elseif consumer then
    if username ~= consumer.username then
      consumer.username = username
      dao:update(consumer, {id = consumer.id})
    end
    return consumer
  else
    consumer, err = findConsumer({ username = username })
    if err then
      return _, err
    elseif consumer then
      if customId ~= consumer.custom_id then
        consumer.custom_id = customId
        dao:update(consumer, {id = consumer.id})
      end
      return consumer
    else
      consumer, err = dao:insert({
        custom_id = customId,
        username = username
      })
      if consumer then
        return consumer
      end
    end
  end
end

local function setConsumer(consumer, userType, userName)
  ngx_set_header(constants.HEADERS.CONSUMER_ID, consumer.id)
  ngx_set_header(constants.HEADERS.CONSUMER_CUSTOM_ID, consumer.custom_id)
  ngx_set_header(constants.HEADERS.CONSUMER_USERNAME, consumer.username)
  ngx_set_header('X-User-Type', userType)
  ngx_set_header('X-User-Name', userName)
  ngx.ctx.authenticated_consumer = consumer  
  ngx.ctx.authenticated_credential = { consumer_id = consumer.id }
end

return _M
