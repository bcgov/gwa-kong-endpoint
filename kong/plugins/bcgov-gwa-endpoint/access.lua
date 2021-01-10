local utils = require "kong.tools.utils"
local singletons = require "kong.singletons"
local constants = require "kong.constants"
--local exit = require "kong.response.exit"
-- local crud = require "kong.api.crud_helpers"
local groups = require "kong.plugins.acl.groups"

local ngx_set_header = ngx.req.set_header
local ngx_get_headers = ngx.req.get_headers
  
local _M = {}

local function loadConsumerByUsername(username)
  if username then
    local consumer, err = kong.db.consumers:select_by_username(username)
    if err then
      return consumer, err
    else
      return consumer
    end
  else
    return nil
  end
end

local function loadConsumerByCustomId(customId)
  if customId then
    local consumer, err = kong.db.consumers:select_by_custom_id(customId)
    if err then
      return consumer, err
    else
      return consumer
    end
  else
    return nil
  end
end

local function loadConsumer(customId, username)
  local consumer, err = kong.cache:get("consumerCustomId."..customId, nil, loadConsumerByCustomId, customId)
  if err then
    kong.log.inspect(err)
    return _, err
  elseif consumer then
    if username ~= consumer.username then
      consumer.username = username
      local entity, err, err_t = kong.db.consumers:update({id = consumer.id}, consumer)
      if err or err_t then
        kong.log.inspect(err)
        kong.log.inspect(err_t)
      end
    end
    return consumer
  else
    consumer, err = kong.cache:get("consumerUsername."..username, nil, loadConsumerByUsername, username)
    if err then
      return _, err
    elseif consumer then
      if customId ~= consumer.custom_id then
        consumer.custom_id = customId
        local entity, err, err_t = kong.db.consumers:update({id = consumer.id}, consumer)
        if err or err_t then
          kong.log.inspect(err)
          kong.log.inspect(err_t)
        end
      end
      return consumer
    else
      consumer, err = kong.db.consumers:insert({
        custom_id = customId,
        username = username
      })
      if err then
        kong.log.inspect(err)
      elseif consumer then
        return consumer
      end
    end
  end
end

local function setConsumer(consumer, userType, userName)
  ngx_set_header(constants.HEADERS.CONSUMER_ID, consumer.id)
  ngx_set_header(constants.HEADERS.CONSUMER_CUSTOM_ID, consumer.custom_id)
  ngx_set_header(constants.HEADERS.CONSUMER_USERNAME, consumer.username)
  ngx_set_header(constants.HEADERS.ANONYMOUS, nil)
  ngx_set_header('X-User-Type', userType)
  ngx_set_header('X-User-Name', userName)
  ngx.ctx.authenticated_consumer = consumer  
  ngx.ctx.authenticated_credential = { consumer_id = consumer.id }
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
      authdirname = authdirname:lower();
      userguid = userguid:lower();
      universalid = universalid:lower();
      local customId = authdirname..'_'..userguid
      local username = universalid..'@'..authdirname

      local consumer = loadConsumer(customId, username)
      if consumer then
        local consumerId = consumer.id
        local consumerGroups = groups.get_consumer_groups(consumerId)

        -- if Consumer has groups, but 'authdirname' is not one of them, then add the group to the consumer
        if not consumerGroups or not groups.consumer_in_groups({authdirname}, consumerGroups) then
          local group, err = kong.db.acls:insert({
            consumer = {id = consumerId},
            group = authdirname
          })
        end
        setConsumer(consumer, authdirname, universalid)
      else
        kong.log.inspect("Loading a consumer failed!")
        return false, {status = 403}
      end
    end
  end
  return true
end

function _M.execute(conf)
  local ok, err = doSiteminderAuthentication(conf)
  if not ok then
    return kong.response.exit(err.status, err.message)
  end
end

return _M
