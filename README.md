# nginx-lua-image-module
基于OpenResty(Nginx)，用Lua脚本实现的图片处理模块，目前实现了缩略图功能

## 说明
目前主要实现图片缩略图功能，可对不同目录配置缩略图尺寸，无图片时可显示一张默认图片，支持多种缩放方式等，后续可基于GraphicsMagick实现更多功能。

#### 文件夹规划
```bash
img.xxx.com
|-- avatars
|   `-- 001
|       `-- 001.jpg
|-- default
|   `-- notfound.jpg
|-- photos
|   `-- 001
|       `-- 001.jpg
`-- thumbnail
    `-- photos
        `-- 001
            |-- 001_100x100.jpg
            |-- 001_140x140.jpg
            |-- 001_250x250.jpg
            |-- 001_300x300.jpg
            |-- 001_350x350.jpg
            |-- 001_50x50.jpg
            `-- abc_50x50.jpg        
```

其中img.xxx.com为图片站点根目录，avatars和photos目录是原图目录，可根据目录设置不同的缩略图尺寸，default文件夹的notfound.jpg文件是在未找到原图时的默认图片，thumbnail文件夹用来存放缩略图，可定时清理。

#### 链接地址
* 原图访问地址：```http://img.xxx.com/photos/001/001.jpg```
* 缩略图访问地址：```http://img.xxx.com/photos/001/001_100x100.jpg``` (请勿加thumbnail)

#### 不同目录可以设置不同的缩略图规则，如
* 原图访问地址：```http://img.xxx.com/mall/001/001.jpg```
* 缩略图访问地址：```http://img.xxx.com/mall/001/001.jpg_100x100.jpg``` (请勿加thumbnail)

#### 访问流程
* 首先判断缩略图是否存在，如存在则直接显示缩略图；
* 如不存在则按以下流程处理：
    1. 判断缩略图链接与规则是否匹配，如不匹配，则404退出；如匹配跳至2
    2. 判断原图是否存在，如原图存在则跳至5，如不存在则进入下一步；
    3. 判断是否显示默认图片，如不显示则404退出；如显示则进入下一步
    4. 判断是否存在默认图片，如不存在则404退出；如存在则将默认图片代替原始图片，进入下一步；
    5. 拼接graphicsmagick命令，生成并显示缩略图

## 配置

配置文件为lua/config.lua，如下

```lua
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

enabled_log 		 = true
lua_log_level        = ngx.NOTICE
gm_path				 = '/usr/local/graphicsmagick-1.3.18/bin/gm'
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
```

## 依赖
* OpenResty(1.4.2.7)
* GraphicsMagick(1.3.18)
  * libjpeg-6b
  * libpng-1.2.49
  * freetype-2.4.10    
* inotify(可选)
