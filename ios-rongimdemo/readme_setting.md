设置页面从上到下依次表示appkey，demo server，导航server，文件server

输入格式：
demo server：sdk会自动为demo server头部拼接“http://”
例如：http://api.sealtalk.im，只需要输入api.sealtalk.im即可

导航server：sdk会自动为导航server头部拼接“http://”，尾部拼接“/navi.xml”，所以只需要手动输入中间的部分即可
例如，http://nav.cn.ronghub.com/navi.xml，只需要输入nav.cn.ronghub.com即可

文件server：sdk会自动为文件server头部拼接“http://”
例如http://upload.qiniu.com，只需要输入upload.qiniu.com即可

点击确定之后会跳入登录页面，如果从登录页面无法正常登录，请检查一下设置页面的四个参数是否正常