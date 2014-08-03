nginx-lua-image-module
===================================
基于OpenResty(Nginx)，用Lua脚本实现的图片处理模块，目前实现了缩略图功能

### 说明
-----------------------------------
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
* 原图访问地址：
```
http://img.xxx.com/photos/001/001.jpg
```
* 缩略图访问地址：```http://img.xxx.com/photos/001/001_100x100.jpg``` (请勿加thumbnail)


#### 访问流程
* 首先判断缩略图是否存在，如存在则直接显示缩略图；
* 如不存在则按以下流程处理：
    1. 判断原图是否存在，如原图不存在则进入下一步；如存在则跳至4
    2. 判断是否显示默认图片，如不显示则404退出；如显示则进入下一步
    3. 判断是否存在默认图片，如不存在则404退出；如存在则将默认图片代替原始图片，进入下一步；
    4. 判断缩略图链接与规则是否匹配，如不匹配，则404退出；如匹配跳至5
    5. 拼接graphicsmagick命令，生成并显示缩略图

### 配置
-----------------------------------
配置文件为lua/config.lua，如下

```lua
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
```
如果允许使用默认图片，则default目录的sizes配置应包含以上目录的sizes，否则会因规则不匹配显示不了默认图片。

### 依赖
-----------------------------------
* OpenResty(1.4.2.7)
* GraphicsMagick(1.3.18)
  * libjpeg-6b
  * libpng-1.2.49
  * freetype-2.4.10    
* inotify(可选)


### 安装
-----------------------------------
请参考：http://www.51ajax.com/blog/?p=1188<br/>

### TODO
-----------------------------------
* 增加更多图片处理功能
* 增加图片上传功能

### 联系
-----------------------------------
hopesoft <hopesoft@126.com>