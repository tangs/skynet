-- package define:[head|data|tail]
-- head:[proto_type(1bit)|seq_id(1bit)|cmd_len(2bits)|cmd_name(cmd_len + 1('\0')bits)|data_len(4bits)]
-- tail:[crc32(4bits)]

local json = require "json"

-- proto 类型(1.json 2.zip json 3.protobuf)
-- 目前支持json
local PROTO_TYPE = {
    json = 1,
    zip_json = 2,
    protobuf = 3,
}

local function encode(seqid, values, cmd)
    local head = string.char(PROTO_TYPE.json & 0xff, seqid & 0xff)
    -- local cmd = values.cmd
    local cmdlen = #cmd
    -- cmd(2bits)
    local cmdlen_bytes = string.char(
        (cmdlen >> 8) & 0xff, 
        cmdlen & 0xff, 
        0x00                    -- append '\0'
    )
    local data = json.encode(values)
    local data_len = #data
    local data_len_bytes = string.char(
        (data_len >> 24) & 0xff,
        (data_len >> 16) & 0xff,
        (data_len >> 8) & 0xff,
        data_len & 0xff
    )
    -- check data(Reserved.)
    local crc32 = string.char(0x00, 0x00, 0x00, 0x00)
    data = head .. cmdlen_bytes .. cmd .. data_len_bytes .. data .. crc32
    return true, data
end

-- ret: true, data(table)
-- ret: false, err_msg(string)
local function decode(dest_seqid, bytes)
    local len = #bytes
    print("len:" .. len)
    -- invalid bytes.
    if len < 8 then return false, "invalid bytes." end
    local idx = 1
    local prototype = bytes:byte(idx)
    idx = idx + 1
    -- unsupport proto type.
    if prototype ~= 1 then return false, "unsupport proto type." end
    local seqid = bytes:byte(idx)
    idx = idx + 1 
    -- check sequnce id fail.
    if seqid ~= dest_seqid then return false, "check sequnce id fail." end
    local cmdLen = (bytes:byte(idx) << 8) | (bytes:byte(idx + 1))
    idx = idx + 2
    print("cmdLen:" .. cmdLen)
    if len < idx + cmdLen + 4 then return false, "invalid bytes1." end
    local cmd = bytes:sub(idx, 4 + cmdLen)
    print("cmd:" .. cmd)
    idx = idx + cmdLen + 1  -- skip cmd len '\0' tail.
    local dataLen = (bytes:byte(idx) << 24) | (bytes:byte(idx + 1) << 16) 
        | (bytes:byte(idx + 2) << 8) | (bytes:byte(idx + 3))
    print("dataLen:" .. dataLen)
    idx = idx + 4
    print("idx:" .. idx)
    if len + 1 ~= idx + dataLen + 4 then return false, "invalid bytes2." end
    local jsonData = bytes:sub(idx, idx + dataLen - 1)
    idx = idx + dataLen
    print("jsonData:" .. jsonData)
    local data = json.decode(jsonData)
    return true, data, cmd
end

return {
    encode = encode,
    decode = decode,
}