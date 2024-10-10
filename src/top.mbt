pub fn start() -> Unit {

}

// struct Position {
//   mut x : Int
//   mut y : Int
// }

// let pos : Position = { x: 0, y: 0 }

fn blitFlag(one_bit_per_pixel:Bool,flip_x:Bool,flip_y:Bool,rotate:Bool)->@wasm4.BlitFlag{
  {one_bit_per_pixel,flip_x,flip_y,rotate};
}
//要写一个@wasm4.BlitFlag生成函数

let length_back:UInt=160;
let inf_index:UInt=160U*160U-1U;
fn get_pixel_index(x:UInt,y:UInt) ->UInt{
  y*length_back+x
}
//x in [0,160)
//y in [0,160)
fn change_pixel(x:UInt,y:UInt,palette:UInt)->Unit{
  @wasm4.set_frame_buffer(get_pixel_index(x,y),palette)
}
//用draw_color中的第 palette 位来填充
//注意，这里直接调用的是调色板，不是draw_color
//palette in [1,4]

fn memset_back_ground(palette:UInt)->Unit{
  for i=0U;i<=inf_index;i=i+1{
    @wasm4.set_frame_buffer(i,palette)
  }
}


pub fn update() -> Unit {
  //操作draw_colors
  @wasm4.set_draw_colors(1,index=1)
  @wasm4.set_draw_colors(2,index=2)
  @wasm4.set_draw_colors(3,index=3)
  @wasm4.set_draw_colors(4,index=4)
  //相当于有两个序列，第一个是调色板，也就是颜色储存的地方，就是这里的第一个参数
  //第二个是使用的颜色序列，也是只有四个空位，每一种画图函数会调用这四个空位中的颜色来作画，index的值就是这四个位置的下标

  //改变某个指定像素
  change_pixel(0,0,1)
  change_pixel(1,0,2)
  change_pixel(2,0,3)
  change_pixel(3,0,4)

  //操作Sprite，输出图像
  //BlitFlag有四个参数，字面意思
  //bytes一位不是一个bit，是8bit，建议使用16进制输入，十进制输入超过10会占16位，有问题！！！！！
  let smeil=@wasm4.sprite(
  b"\xc3\x81\x24\x24\x00\x24\x99\xc3"
    // b"\xaa\x9e\xac\xaa\xaa\x57\xbf\x2a\xaa\x57\xbf\x2a\xaa\x17\xbf\x2a\xaa\x17\x03\x2a\xaa\x57\x54\x2a\xa8\x55\x55\x6a\xa9\x55\x05\x0a\xaf\xd5\x55\x4a\xa8\x75\x55\x4a\xaa\xd5\x57\x2a\xaa\x1d\x7c\xaa\xa8\x75\x15\x2a\xa8\x45\x15\x2a\xaa\x10\x54\xaa\xaa\x85\x52\xaa"
  )
  let dd: @wasm4.BlitFlag= {one_bit_per_pixel:true,flip_x:false,flip_y:false,rotate:false}
  @wasm4.blit(smeil,0,17,8,8,dd)
  //在one_bit 状态下 sprite中 0代表第一种像素，1代表第二种
  let png=@wasm4.sprite(
    b"\xaa\x9e\xac\xaa\xaa\x57\xbf\x2a\xaa\x57\xbf\x2a\xaa\x17\xbf\x2a\xaa\x17\x03\x2a\xaa\x57\x54\x2a\xa8\x55\x55\x6a\xa9\x55\x05\x0a\xaf\xd5\x55\x4a\xa8\x75\x55\x4a\xaa\xd5\x57\x2a\xaa\x1d\x7c\xaa\xa8\x75\x15\x2a\xa8\x45\x15\x2a\xaa\x10\x54\xaa\xaa\x85\x52\xaa"
  )
  //在two_bit状态下，我们的对应表如下[Sprit ID,draw_color ID] [2,3] [1,2] [3,4] [0,1]
  let aa={..dd,one_bit_per_pixel:false}
  @wasm4.blit(png,0,1,16,16,aa)
  //我们好像用不了 Custom template
  //就用 w4 png2src --assemblyscript *.png 吧

  //text
  @wasm4.text("123\x87456里",16,0)
  //在Wasm4中，text函数用于在屏幕上绘制文本。它的输出是将指定的字符串绘制在屏幕的指定位置。具体来说，text函数会在指定的坐标处逐个字符地绘制字符串，每个字符占用8x8像素的空间。
  //有现成的箭头可以输出，但是好像有bug，还是自己写吧QWQ
  //可以自定义字体，但是本质是sprite

  //Playing Audio
  @wasm4.tone((240,500),@wasm4.ADSR::new(333),@wasm4.ADSRVolume::new(222),@wasm4.ToneFlag::new(channel=Pulse2,mode=Duty_1_8,pan=Left))
  //会不了一点，求教QWQ
  //https://wasm4.org/docs/guides/audio
}



// wasm4提供绘制矩形，线条，椭圆，圆的功能
// wasm为直接操作当前帧提供了办法
// wasm可以读入鼠标，手柄
// wasm可以输出一个已经编辑好的图像，并且为这个图像提供了基本的操作（*）

// - https://wasm4.org/docs/ 用于了解wasm4可以拿来干些啥
// - https://www.moonbitlang.cn/blog/wasm4 知道怎么安装并引用wasm4的库，并且了解wasm4开发时的项目文件结构（主要就是了解怎么从mooncake中下载包，以及如何引用自己的包）
// - https://mooncakes.io/docs/#/moonbitlang/wasm4/?id=prerequisites 用于了解moonbit中的wasm4库应当怎么使用（不用每项都看，只用了解在wasm4.org中呈现的基础内容，到时候不会再查）
// - moonbit 包管理教程 知道如何配置包的配置文件
// - 在这周结束之前我会写完项目整体构架，然后我们开始写代码
// - 如果对moonbit还不太熟悉的，抓紧熟悉一下（写游戏对moonbit的要求不高，主要看函数，接口，数据结构，方法，以及基础类型，权限控制）