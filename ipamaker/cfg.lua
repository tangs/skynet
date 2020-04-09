-- 下载地址跟路径
local download_path_root = "/var/www/html/apps/"
local apple_accouts = {
    {
        name = "acc1",
        fastlane = "/home/ubuntu/Documents/fastlane_prjs/app1"
    },
    {
        name = "acc2",
        fastlane = "/home/ubuntu/Documents/fastlane_prjs/app2"
    },
}

return {
    download_path_root = download_path_root,
    apple_accouts = apple_accouts
}
