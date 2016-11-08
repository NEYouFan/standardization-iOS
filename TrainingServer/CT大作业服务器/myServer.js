var redis = require('redis');
var http = require('http');
var url = require("url");
var querystring = require("querystring");
var sys       = require('sys');
var path      = require('path');
var fs        = require('fs');
var exec = require('child_process').exec;
var express = require('express');
var morgan = require('morgan');
var multipart = require('connect-multiparty');

var app = express();
app.use(express.static('./public'));
app.use(morgan('dev'));

app.listen(process.env.PORT || 3000);
console.log('Node.js Ajax Upload File running at: http://0.0.0.0:3000');

// app.post('/upload', multipart(), function(req, res){
//   // console.log("0:", req);
//   console.log("1:", req.filename);
//   console.log("2:", req.files);
//   console.log("3:", req.files.files);
//   console.log("4:", req.files.filename);

//   //get filename
//   // var filename = req.files.files.originalFilename || path.basename(req.files.files.ws.path);
//   // var filename = req.files.files.originalFilename || path.basename(req.files.files.ws.path);
//   var filename = req.files.originalFilename;

//   console.log("5");

//   //copy file to a public directory
//   var targetPath = path.dirname(__filename) + '/public/' + filename;
//   console.log("6");

//   console.log(req.files.files.ws.path);

//   //copy file
//   // fs.createReadStream(req.files.files.ws.path).pipe(fs.createWriteStream(targetPath));
//   fs.createReadStream(req.files.files.ws.path).pipe(fs.createWriteStream(targetPath));

//   //return file url
//   res.json({code: 200, msg: {url: 'http://' + req.headers.host + '/' + filename}});
// });


app.post('/upload', multipart(), function(req, res){
  // console.log("0:", req);
  console.log("1:", req.filename);

  // Note: 这里是对应   { 'content-disposition': 'form-data; name="files"; filename="image"', 'content-type': 'image/jpeg' },来的
  // 如果name是"lwangName", 那么要变成req.lwangName.files...也就是中间的files要替换掉的
  console.log("2:", req.files);
  console.log("3:", req.files.files);
  console.log("4:", req.files.filename);

  //get filename
  var filename = req.files.files.originalFilename || path.basename(req.files.files.ws.path);
  // var filename = req.files.files.originalFilename || path.basename(req.files.files.ws.path);

  console.log("5");

  //copy file to a public directory
  var targetPath = path.dirname(__filename) + '/public/' + filename;
  console.log("6");

  console.log(req.files.files.ws.path);

  //copy file
  // fs.createReadStream(req.files.files.ws.path).pipe(fs.createWriteStream(targetPath));
  fs.createReadStream(req.files.files.ws.path).pipe(fs.createWriteStream(targetPath));

  //return file url
  res.json({code: 200, msg: {url: 'http://' + req.headers.host + '/' + filename}});
});




app.get('/env', function(req, res){
  console.log("process.env.VCAP_SERVICES: ", process.env.VCAP_SERVICES);
  console.log("process.env.DATABASE_URL: ", process.env.DATABASE_URL);
  console.log("process.env.VCAP_APPLICATION: ", process.env.VCAP_APPLICATION);
  res.json({
    code: 200
    , msg: {
      VCAP_SERVICES: process.env.VCAP_SERVICES
      , DATABASE_URL: process.env.DATABASE_URL
    }
  });
});

app.get('/user', function(req, res) {
  var uri = url.parse(req.url, true);
  console.log(uri);
  var filename = path.join(process.cwd(), uri.pathname);
  if (uri.pathname == "/products" || uri.pathname == "/photolist") {
      var offset = parseInt(uri.query["offset"]) / 20;
      filename = filename + offset;
  }

  console.log("get: " + filename);

  if (fs.existsSync(filename))
  {
    res.writeHead(200, {'Content-Type':'application/octet-stream'});
    var fstat = fs.lstatSync(filename);
    res.end(fs.readFileSync(filename));
    console.log('finished get');
  } 
});

app.get('/spec', function(req, res) {
  var uri = url.parse(req.url, true);
  console.log(uri);
  var filename = path.join(process.cwd(), uri.pathname);
  console.log("get: " + filename);

  if (fs.existsSync(filename))
  {
    res.writeHead(200, {'Content-Type':'application/octet-stream'});
    var fstat = fs.lstatSync(filename);
    res.end(fs.readFileSync(filename));
    console.log('finished get');
  } 
});

app.get('/specTest', function(req, res) {
  var uri = url.parse(req.url, true);
  console.log(uri);
  var filename = path.join(process.cwd(), uri.pathname);
  console.log("get: " + filename);

  if (fs.existsSync(filename))
  {
    res.writeHead(200, {'Content-Type':'application/octet-stream'});
    var fstat = fs.lstatSync(filename);
    res.end(fs.readFileSync(filename));
    console.log('finished get');
  } 
});


app.get('/products', function(req, res) {
  var uri = url.parse(req.url, true);
  console.log(uri);
  var filename = path.join(process.cwd(), uri.pathname);
  if (uri.pathname == "/products" || uri.pathname == "/photolist") {
      var offset = parseInt(uri.query["offset"]) / 20;
      filename = filename + offset;
  }

  console.log("get: " + filename);

  if (fs.existsSync(filename))
  {
    res.writeHead(200, {'Content-Type':'application/octet-stream'});
    var fstat = fs.lstatSync(filename);
    res.end(fs.readFileSync(filename));
    console.log('finished get');
  } 
});

app.get('/photolist', function(req, res) {
  var uri = url.parse(req.url, true);
  console.log(uri);
  var filename = path.join(process.cwd(), uri.pathname);
  console.log("filename: ", filename);
  if (uri.pathname == "/products" || uri.pathname == "/photolist") {
      var offset = parseInt(parseInt(uri.query["offset"]) / 20);
      console.log("offset:", offset);
      filename = filename + offset;
  }

  console.log("get: " + filename);

  if (fs.existsSync(filename))
  {
    res.writeHead(200, {'Content-Type':'application/octet-stream'});
    var fstat = fs.lstatSync(filename);
    res.end(fs.readFileSync(filename));
    console.log('finished get');
  } 
});

// Post
app.post('/collection', function(req, res) {
  req.setEncoding('utf-8');
  var postData = ""; //POST & GET ： name=zzl&email=zzl@sina.com
  // 数据块接收中
  req.addListener("data", function (postDataChunk) {
      postData += postDataChunk;
  });

  // 数据接收完毕，执行回调函数
  req.addListener("end", function () {
    console.log('数据接收完毕');
    // //解析POST数据{name="zzl",email="zzl@sina.com"}
    var params = querystring.parse(postData);
    console.log(params);
    console.log(params["name"]);
    console.log(params["email"]);
    var name = params["name"];
    var type = params["type"];
    if (name) {
        PushToRedis(params["name"]);    
    }    
    

    if (type == "photolist") {
      // 返回指定的数据
      var filename = type + '_' + name;
      console.log("require filename:", filename);
      if (fs.existsSync(filename)) {
        res.writeHead(200, {'Content-Type':'application/octet-stream'});
        var fstat = fs.lstatSync(filename);
        res.end(fs.readFileSync(filename));
      } else {
        res.json({code: 201, result: 1, message:'no data'});  
      }
    } else {
      res.json({code: 200, result: 0, message:'successful'});
    }
  });
});

//表单接收完成后，再处理redis部分
function PushToRedis(info) {
    console.log("StartPushToRedis:" + info);
    var client = redis.createClient();
    console.log("StartPushToRedis2:" + info);
    client.lpush("topnews", info);
    console.log("PushToRedis:" + info);
    client.lpop("topnews", function (i, o) {
        console.log(o);//回调，所以info可能没法得到o的值，就被res.write输出了
    })
    client.quit();
}