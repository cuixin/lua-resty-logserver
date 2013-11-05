--encoding=utf-8

local mysql = require "resty.mysql"

local HOST = ngx.var.MYSQL_HOST
local PORT = tonumber(ngx.var.MYSQL_PORT)
local DATABASE = ngx.var.MYSQL_DATABASE
local USER = ngx.var.MYSQL_USER
local PASSWORD = ngx.var.MYSQL_PASSWORD
local print = ngx.say

module(..., package.seeall)

function append(tab, args)
    local db, err = mysql:new()
    if not db then
        print("failed to instantiate mysql: ", err)
        return
    end

    db:set_timeout(1000) -- 1 sec
    local ok, err, errno, sqlstate = db:connect{
        host = HOST,
        port = PORT,
        database = DATABASE,
        user = USER,
        password = PASSWORD,
        max_packet_size = 1024 * 1024}

    if not ok then
        print("failed to connect: ", err, ": ", errno, " ", sqlstate)
        return
    end

    local basesql = string.format("insert into `%s`", tab)

    local fields, values = " (", " values ("
    for k, v in pairs(args) do
        fields = fields .. k .. ","
        values = values .. v .. ","
    end
    if string.sub(fields, -1)== "," then
        fields = string.sub(fields, 1, -2)
        values = string.sub(values, 1, -2)
    end

    fields = fields .. ")"
    values = values .. ")"
    local sql = basesql .. fields .. values
    local res, err, errno, sqlstate = db:query(sql)

    if not res then
        print("bad result: ", err, ": ", errno, ": ", sqlstate, ".")
        return
    end

    -- print(res.affected_rows, " rows inserted into table ", "(last insert id: ", res.insert_id, ")")
    print('ok')
    -- put it into the connection pool of size 100,
    -- with 10 seconds max idle timeout
    local ok, err = db:set_keepalive(10000, 100)
    if not ok then
        print("failed to set keepalive: ", err)
        return
    end
end
