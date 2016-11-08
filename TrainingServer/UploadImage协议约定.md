(lldb) po multipartRequest.allHTTPHeaderFields
{
    Accept = "application/json";
    "Accept-Language" = "en-US;q=1";
    "Content-Length" = 141742;
    "Content-Type" = "multipart/form-data; boundary=Boundary+E7A28EFC692FCAE8";
    "User-Agent" = "HTHttpDemo/1 (iPhone; iOS 9.2; Scale/3.00)";
}

{
    "Content-Disposition" = "form-data; name=\"files\"; filename=\"lwang.jpg\"";
    "Content-Type" = "image/jpeg";
}

上传的文件在public目录下!