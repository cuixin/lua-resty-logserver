--encoding=utf-8

local mysql = require "resty.mysql"
local cjson = require "cjson"
local log = require('mysqllog')

local args = ngx.req.get_uri_args()

if args.tab ~= nil then
    local tab = args.tab
    args['tab'] = nil
    for k, v in pairs(args) do
        args[k] = ngx.quote_sql_str(v)
    end
    log.append(tab, args)
end