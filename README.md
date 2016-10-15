# InOutLabel
字体的渐隐渐现、渐进渐出
仿RQShineLabel:https://github.com/zipme/RQShineLabel
附带全解析
/**
 
 设置ADLabel的text内容时，就会通过text的set方法将字符串转换成可变字符串
 通过可变字符串的set方法，将字符串中的字符颜色透明度都设置为0并赋值给ADLabel
 并为每个字符设置一个随机并基于动画时间而生成的淡出时间保存在数组中
 
 shine方法:动画开启并没有指定完成后的操作
 shineWithCompletion: 动画开启并指定完成后的操作
 调用shine方法后会调用shineWithCompletion，传过去的操作为nil
 在shineWithCompletion方法中会完成保存操作,并设置淡出效果为NO,而后开启动画
 
 开启动画:startAnimationWithDuration
 其中会获取当前时间为开始时间，开始时间加字体渐近时间shineDuration为结束时间
 通过取消帧动画的暂停开启帧动画updateAttributedString
 
 帧动画里会获取当前时间用于判断是否超出动画时间
 遍历可变字符串的每个字符，并修改除空格、回车(包含'\n')、tab之外的字符的透明度
 透明度是否修改通过以下方式判断：
 1.淡出效果并且透明度大于0
 2.不是淡出效果并且透明度小于1
 3.当前时间 - 动画开始时间 >= 基于淡出效果而生成的一个随机时间
 应该更新则获取所需透明度值 : 当前时间 - 开始时间 - 基于淡出效果而生成的一个随机时间
 如果是淡出状态就获取 1 - 透明度值
 修改完后设置可变字符串内容
 并判断如果当前时间超过动画结束时间，暂停帧动画，执行结束操作
 
 至此，动画效果完成
 
 fadeOut: 手动开启淡出效果但没有结束后的操作
 fadeOutWithCompletion: 手动开启淡出效果并有结束后的操作
 */
