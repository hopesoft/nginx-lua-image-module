-- nginx thumbnail module 
-- last update : 2014/8/3
-- version     : 0.4

module(...,package.seeall)

enabled_log 		 = true
enabled_default_img  = true
default_img_uri 	 = '/default/notfound.jpg' 
gm_path				 = '/usr/local/graphicsmagick-1.3.18/bin/gm'
img_background_color = 'white'
lua_log_level        = ngx.NOTICE

--[[ 
	配置项，对目录、缩略图尺寸、裁剪类型进行配置，匹配后才进行缩略图处理
	1.sizes={'350x350'} 填充后保证等比缩图
	2.sizes={'300x300_'}等比缩图
	3.sizes={'250x250!'}非等比缩图，按给定的参数缩图（缺点：长宽比会变化）	
	4.sizes={'50x50^'}裁剪后保证等比缩图 （缺点：裁剪了图片的一部分）	
	5.sizes={'100x100>'}只缩小不放大		
	6.sizes={'140x140$'}限制宽度，只缩小不放大(比如网页版图片用于手机版时)	
]]
cfg = {
		{
			dir   = 'photos',
			sizes = {'50x50^','100x100>','140x140$','250x250!','300x300_','350x350'}
		},
		{	dir   = 'avatars',
			sizes = {'50x50^','80x80'}
		},
		{	dir   = 'default',
			sizes = {'50x50^','100x100>','140x140$','250x250!','300x300_','350x350','80x80'}
		}
}