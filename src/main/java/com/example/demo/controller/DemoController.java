package com.example.demo.controller;

import org.springframework.util.StopWatch;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import java.lang.management.ManagementFactory;
import java.lang.management.MemoryMXBean;
import java.util.HashMap;
import java.util.Map;

/**
 * Created by M1873 on 2020/8/22.
 */
@RestController
public class DemoController {

    @RequestMapping("info")
    public Map info(HttpServletRequest request, String a){
        StopWatch sw = new StopWatch("test");
        sw.start("info");
        HashMap map = new HashMap();
        Cookie[] cookie = request.getCookies();
        String header = request.getHeader("name");
        sw.stop();
        map.put("cookie",cookie[0].getValue());
        map.put("header",header);
        map.put("参数",a);
        map.put("耗时",sw.prettyPrint());
        return map;
    }

    @RequestMapping("jvmParam")
    public Object param(){
        MemoryMXBean mxb = ManagementFactory.getMemoryMXBean();
        return mxb;
    }
}
