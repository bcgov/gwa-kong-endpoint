local utils = require "kong.tools.utils"
local singletons = require "kong.singletons"
local constants = require "kong.constants"
local responses = require "kong.tools.responses"

local ngx_set_header = ngx.req.set_header
local ngx_get_headers = ngx.req.get_headers
  
local _M = {}

local function loadConsumerGroup(consumer_id, group)
  local dao = singletons.dao.acls
  local groups, err = dao:find_all({consumer_id = consumer_id, group = group})
  if err then
    return groups, err
  else
    for _, group in ipairs(groups) do
      return group
    end
  end
end

local function loadConsumerByParameters(parameters)
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

local function loadConsumerByUsername(username)
  return loadConsumerByParameters({ username = username });
end

local function loadConsumerByCustomId(customId)
  return loadConsumerByParameters({ custom_id = customId });
end

local function loadConsumer(customId, username)
  local cache = singletons.cache
  local dao = singletons.dao.consumers
  local consumer, err = singletons.cache:get("consumerCustomId."..customId, nil, loadConsumerByCustomId, customId)
  if err then
    return _, err
  elseif consumer then
    if username ~= consumer.username then
      consumer.username = username
      dao:update(consumer, {id = consumer.id})
    end
    return consumer
  else
    consumer, err = cache:get("consumerUsername."..username, nil, loadConsumerByUsername, username)
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

local function doSiteminderAuthentication(conf)
  local cache = singletons.cache
  local headers = ngx_get_headers()
  local userguid = headers["smgov_userguid"]
  if userguid then
    local authdirname = headers["sm_authdirname"]
    local universalid = headers["sm_universalid"]
    if not (authdirname and universalid) then
      return false, {status = 403}
    else
      authdirname = authdirname:lower();
      userguid = userguid:lower();
      universalid = universalid:lower();
      local customId = authdirname..'_'..userguid
      local username = authdirname..'_'..universalid
      local consumer = loadConsumer(customId, username)
      if consumer then
        local consumerId = consumer.id
        local group, err = cache:get("consumerGroup."..consumerId..authdirname, nil, loadConsumerGroup, consumerId, authdirname)
        if err then
          return false, {status = 403}
        elseif group then
        else
          local aclsDao = singletons.dao.acls
          group, err = aclsDao:insert({
            consumer_id = consumerId,
            group = authdirname
          })
        end
        setConsumer(consumer, authdirname, universalid)
      else
        return false, {status = 403}
      end
    end
  end
  return true
end

function _M.execute(conf)
  local ok, err = doSiteminderAuthentication(conf)
  if not ok then
    return responses.send(err.status, err.message)
  end
end

return _M
