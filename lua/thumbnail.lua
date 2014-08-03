-- nginx thumbnail module 
-- last update : 2014/8/3
-- version     : 0.4

local c  = require 'config'

--[[
	uri               :链接地址，如/goods/0007/541/001_328x328.jpg
	ngx_img_root      :图片根目录
	ngx_thumbnail_root:缩略图根目录
	img_width         :缩略图宽度 
	img_width         :缩略图高度
	img_size          :缩略图宽x高
	img_crop_type     :缩略图裁剪类型
]]
local uri = ngx.var.uri;
local ngx_img_root = ngx.var.image_root;
local ngx_thumbnail_root = ngx.var.thumbnail_root;
local img_width,img_height,img_size,img_crop_type = 0;

--[[
	日志函数
	log_level: 默认为ngx.NOTICE
	取值范围：ngx.STDERR , ngx.EMERG , ngx.ALERT , ngx.CRIT , ngx.ERR , ngx.WARN , ngx.NOTICE , ngx.INFO , ngx.DEBUG
	请配合nginx.conf中error_log的日志级别使用
]]
function lua_log(msg,log_level)
	log_level = log_level or c.lua_log_level
    if(c.enabled_log) then 
		ngx.log(log_level,msg) 
	end
end

--	匹配链接对应缩略图规则
function table.contains(table,element)
    for _, value in pairs(c.cfg) do
        local dir = value['dir'];
        local sizes = value['sizes'];
        _,_,img_width,img_height = string.find(uri,''..dir..'+.*_([0-9]+)x([0-9]+)');
        if(img_width and img_height ) then
            img_size = img_width..'x'..img_height;
            for _, value in pairs(sizes) do
                if (img_size == value) then
                    img_crop_type=1;
                    return true;
                elseif (img_size..'_' == value) then
                    img_crop_type=2;
                    return true;					
                elseif (img_size..'!' == value) then
                    img_crop_type=3;
                    return true;
                elseif (img_size..'^' == value) then
                    img_crop_type=4;
                    return true;
                elseif (img_size..'>' == value) then
                    img_crop_type=5;
                    return true;
                elseif (img_size..'$' == value) then
                    img_crop_type=6;
                    img_size = img_width..'x';
                    return true;					
                end
            end
        end
    end
    return false
end

-- 拼接gm命令
local function generate_gm_command(img_crop_type,img_original_path,img_size,img_thumbnail_path)
	local cmd
	cmd = c.gm_path .. ' convert ' .. img_original_path
	
	if (img_crop_type == 1) then
		cmd = cmd .. ' -thumbnail '  .. img_size .. ' -background ' .. c.img_background_color .. ' -gravity center -extent ' .. img_size
	elseif (img_crop_type == 2) then
		cmd = cmd .. ' -thumbnail '  .. img_size	
	elseif (img_crop_type == 3) then
		cmd = cmd .. ' -thumbnail "'  .. img_size .. '!" -extent ' .. img_size
	elseif (img_crop_type == 4) then
		cmd = cmd .. ' -thumbnail "'  .. img_size .. '^" -extent ' .. img_size
	elseif (img_crop_type == 5 or img_crop_type == 6) then
		cmd = cmd .. ' -resize "'  .. img_size .. '>"'
	else
		lua_log('img_crop_type error:'..img_crop_type,ngx.ERR);
		ngx.exit(404);
	end	
	cmd = cmd .. ' ' .. img_thumbnail_path
	return cmd
end

lua_log("ngx_thumbnail_root======="..ngx_thumbnail_root)

--[[
	1.判断原图是否存在，如原图不存在则进入下一步；如存在则跳至4
	2.判断是否显示默认图片，如不显示则404退出；如显示则进入下一步
	3.判断是否存在默认图片，如不存在则404退出；如存在则将默认图片代替原始图片，进入下一步；	
]]
local img_original_uri = string.gsub(uri, '_[0-9]+x[0-9]+','');
local img_exist=io.open(ngx_img_root .. img_original_uri);
if not img_exist then
    if not c.enabled_default_img then
        lua_log(img_original_uri..' is not exist!',ngx.ERR);
        ngx.exit(404);
    else
        img_exist=io.open(ngx_img_root ..  c.default_img_uri);
        if img_exist then
            lua_log(img_original_uri .. 'is not exist! crop image with default image');
            img_original_uri = c.default_img_uri;
        else
            lua_log(img_original_uri..' is not exist!',ngx.ERR);
            ngx.exit(404);
        end
    end;
end;

--[[
	4.判断缩略图链接与规则是否匹配，如不匹配，则404退出；如匹配跳至5
	5.拼接graphicsmagick，并执行
]]
if not table.contains(c.cfg, uri) then
    lua_log(uri..' is not match!',ngx.ERR);
    ngx.exit(404);
else
    local img_original_path  = ngx_img_root .. img_original_uri
    local img_thumbnail_path = ngx_thumbnail_root .. uri
    local gm_command         = generate_gm_command(img_crop_type,img_original_path,img_size,img_thumbnail_path)
	
    if (gm_command) then
		lua_log('gm_command======'..gm_command);
        _,_,img_thumbnail_dir,img__thumbnail_filename=string.find(img_thumbnail_path,'(.-)([^/]*)$')
        os.execute('mkdir -p '..img_thumbnail_dir);
        os.execute(gm_command);
    end
    ngx.req.set_uri('/thumbnail'..uri);
end