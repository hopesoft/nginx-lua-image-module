-- nginx thumbnail module 
-- last update : 2014/8/21
-- version     : 0.4.1

module(...,package.seeall)

--[[
	enabled_log：			是否打开日志
	lua_log_level：			日志记录级别
	gm_path：				graphicsmagick安装目录
	img_background_color：	填充背景色
	enabled_default_img：	是否显示默认图片
	default_img_uri：		默认图片链接	
	default_uri_reg：		缩略图正则匹配模式，可自定义
		_[0-9]+x[0-9]						对应：001_100x100.jpg
		_[0-9]+x[0-9]+[.jpg|.png|.gif]+ 	对应：001.jpg_100x100.jpg
]]

enabled_log          = true
lua_log_level        = ngx.NOTICE
gm_path	             = '/usr/local/graphicsmagick-1.3.18/bin/gm'
img_background_color = 'white'
enabled_default_img  = true
default_img_uri 	 = '/default/notfound.jpg' 
default_uri_reg      = '_[0-9]+x[0-9]+' 

--[[ 
	配置项，对目录、缩略图尺寸、裁剪类型进行配置，匹配后才进行缩略图处理
	1.sizes={'350x350'} 填充后保证等比缩图
	2.sizes={'300x300_'}等比缩图
	3.sizes={'250x250!'}非等比缩图，按给定的参数缩图（缺点：长宽比会变化）	
	4.sizes={'50x50^'}裁剪后保证等比缩图 （缺点：裁剪了图片的一部分）	
	5.sizes={'100x100>'}只缩小不放大		
	6.sizes={'140x140$'}限制宽度，只缩小不放大(比如网页版图片用于手机版时)	
	
	dir="/"       对应根目录，请放在default之前
	dir="default" 对应默认图片尺寸，当原图不存在时，请求该尺寸会以默认图片生成缩略图
]]
cfg = {
		{
			dir   = 'photos',
			sizes = {'50x50^','100x100>','140x140$','250x250!','300x300_','350x350'},
		},
		{	dir   = 'avatars',
			sizes = {'50x50^','80x80'},
		},
		{
			dir      = 'mall',
			sizes    = {'130x130!','228x228!','420x420!'},
			uri_reg  = '_[0-9]+x[0-9]+[.jpg|.png|.gif]+',
		},		
		{	dir   = 'default',
			sizes = {'50x50^','100x100>','140x140$','250x250!','300x300_','350x350','80x80'},
		}
}
