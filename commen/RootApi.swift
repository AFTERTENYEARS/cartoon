//
//  RootApi.swift
//  practice_1203
//
//  Created by 李书康 on 2018/12/5.
//  Copyright © 2018 com.li.www. All rights reserved.
//

import Foundation
import Moya
import HandyJSON
import SVProgressHUD
import SwiftyJSON

var topVC: UIViewController? {
    var resultVC: UIViewController?
    resultVC = _topVC(UIApplication.shared.keyWindow?.rootViewController)
    while resultVC?.presentedViewController != nil {
        resultVC = _topVC(resultVC?.presentedViewController)
    }
    return resultVC
}

private  func _topVC(_ vc: UIViewController?) -> UIViewController? {
    if vc is UINavigationController {
        return _topVC((vc as? UINavigationController)?.topViewController)
    } else if vc is UITabBarController {
        return _topVC((vc as? UITabBarController)?.selectedViewController)
    } else {
        return vc
    }
}



let timeoutClosure = {(endpoint: Endpoint, closure: MoyaProvider<API>.RequestResultClosure) -> Void in
    
    if var urlRequest = try? endpoint.urlRequest() {
        urlRequest.timeoutInterval = 20
        closure(.success(urlRequest))
    } else {
        closure(.failure(MoyaError.requestMapping(endpoint.url)))
    }
}

enum API {
    case searchHot//搜索热门
    case searchRelative(inputText: String)//相关搜索
    case searchResult(argCon: Int, q: String)//搜索结果
    
    case favList //收藏列表
    case todayList//今日列表
    case historyList // 阅读历史列表
    case boutiqueList(sexType: Int)//推荐列表
    case special(argCon: Int, page: Int)//专题
    case vipList//VIP列表
    case subscribeList//订阅列表
    case rankList//排行列表
    
    case cateList//分类列表
    
    case comicList(argCon: Int, argName: String, argValue: Int, page: Int)//漫画列表
    
    case guessLike//猜你喜欢
    
    case detailStatic(comicid: Int)//详情(基本)
    case detailRealtime(comicid: Int)//详情(实时)
    case commentList(object_id: Int, thread_id: Int, page: Int)//评论
    
    case chapter(chapter_id: Int)//章节内容
}

extension API: TargetType {
    private struct UApiKey {
        static var key = "fabe6953ce6a1b8738bd2cabebf893a472d2b6274ef7ef6f6a5dc7171e5cafb14933ae65c70bceb97e0e9d47af6324d50394ba70c1bb462e0ed18b88b26095a82be87bc9eddf8e548a2a3859274b25bd0ecfce13e81f8317cfafa822d8ee486fe2c43e7acd93e9f19fdae5c628266dc4762060f6026c5ca83e865844fc6beea59822ed4a70f5288c25edb1367700ebf5c78a27f5cce53036f1dac4a776588cd890cd54f9e5a7adcaeec340c7a69cd986:::open"
    }
    
    var baseURL: URL { return URL(string: "http://app.u17.com/v3/appV3_3/ios/phone/")! }
    
    var path: String {
        switch self {
        case .searchHot: return "search/hotkeywordsnew"
        case .searchRelative: return "search/relative"
        case .searchResult: return "search/searchResult"
            
        case .favList: return "fav/index"
        case .todayList: return "comic/todayRecommend"
        case .historyList: return "read/readhistory"
        case .boutiqueList: return "comic/boutiqueListNew"
        case .special: return "comic/special"
        case .vipList: return "list/vipList"
        case .subscribeList: return "list/newSubscribeList"
        case .rankList: return "rank/list"
            
        case .cateList: return "sort/mobileCateList"
            
        case .comicList: return "list/commonComicList"
            
        case .guessLike: return "comic/guessLike"
            
        case .detailStatic: return "comic/detail_static_new"
        case .detailRealtime: return "comic/detail_realtime"
        case .commentList: return "comment/list"
            
        case .chapter: return "comic/chapterNew"
        }
    }
    
    var method: Moya.Method { return .get }
    var task: Task {
        var parmeters = ["time": Int32(Date().timeIntervalSince1970),
                         "device_id": UIDevice.current.identifierForVendor!.uuidString,
                         "key": UApiKey.key,
                         "model": "none",
                         "target": "U17_3.0",
                         "version": Bundle.main.infoDictionary!["CFBundleShortVersionString"]!]
        switch self {
        case .searchRelative(let inputText):
            parmeters["inputText"] = inputText
            
        case .searchResult(let argCon, let q):
            parmeters["argCon"] = argCon
            parmeters["q"] = q
            
        case .boutiqueList(let sexType):
            parmeters["sexType"] = sexType
            parmeters["v"] = 3320101
            
        case .special(let argCon,let page):
            parmeters["argCon"] = argCon
            parmeters["page"] = max(1, page)
            
        case .cateList:
            parmeters["v"] = 2
            
        case .comicList(let argCon, let argName, let argValue, let page):
            parmeters["argCon"] = argCon
            if argName.count > 0 { parmeters["argName"] = argName }
            parmeters["argValue"] = argValue
            parmeters["page"] = max(1, page)
            
        case .detailStatic(let comicid),
             .detailRealtime(let comicid):
            parmeters["comicid"] = comicid
            parmeters["v"] = 3320101
            
        case .commentList(let object_id, let thread_id, let page):
            parmeters["object_id"] = object_id
            parmeters["thread_id"] = thread_id
            parmeters["page"] = page
            
        case .chapter(let chapter_id):
            parmeters["chapter_id"] = chapter_id
            
        default: break
        }
        
        return .requestParameters(parameters: parmeters, encoding: URLEncoding.default)
    }
    
    var sampleData: Data { return "".data(using: String.Encoding.utf8)! }
    var headers: [String : String]? { return nil }
}

let ApiProvider = MoyaProvider<API>(requestClosure: timeoutClosure)

let Provider = MoyaProvider<API>(endpointClosure: myEndpointClosure, requestClosure: requestClosure, plugins: [networkPlugin], trackInflights: false)

///先添加一个闭包用于成功时后台返回数据的回调
typealias successCallback = ((JSON) -> (Void))
typealias failureCallback = ((String) -> (Void))

func NetWorkRequest(_ target: API, completion: @escaping successCallback, failure: @escaping failureCallback){
    //先判断网络是否有链接 没有的话直接返回--代码略
    
    //显示hud
    Provider.request(target) { (result) in
        //隐藏hud
        switch result {
        case let .success(response):
            do {
                switch target {
                default:
                    //这里转JSON用的swiftyJSON框架
                    let jsonData = try JSON(data: response.data)
                    completion(jsonData)
                    //                    //判断后台返回是否有问题
                    //                    if jsonData["payload"] == JSON.init(NSNull()) {
                    //                        failure(jsonData["error"].stringValue)
                    //                    } else {
                    //                        completion(jsonData["payload"])
                    //                    }
                }
            } catch {
            }
        case let .failure(error):
            print(error)
            //            guard (error as? CustomStringConvertible) != nil else {
            //                //网络连接失败，提示用户
            //                print("网络连接失败")
            //                break
            //            }
        }
    }
}


/// 超时时长
private var requestTimeOut:Double = 30
///endpointClosure
private let myEndpointClosure = { (target: API) -> Endpoint in
    ///这里的endpointClosure和网上其他实现有些不太一样。
    ///主要是为了解决URL带有？无法请求正确的链接地址的bug
    let url = target.baseURL.absoluteString + target.path
    var endpoint = Endpoint(
        url: url,
        sampleResponseClosure: { .networkResponse(200, target.sampleData) },
        method: target.method,
        task: target.task,
        httpHeaderFields: target.headers
    )
    switch target {
    default:
        requestTimeOut = 30//设置默认的超时时长
        return endpoint
    }
}

private let requestClosure = { (endpoint: Endpoint, done: MoyaProvider.RequestResultClosure) in
    do {
        var request = try endpoint.urlRequest()
        //设置请求时长
        request.timeoutInterval = requestTimeOut
        // 打印请求参数
        if let requestData = request.httpBody {
            //print("url \(request.url!)"+"\n"+"请求方式 "+"\(request.httpMethod ?? "")"+"\n"+"参数 "+"\(String(data: request.httpBody!, encoding: String.Encoding.utf8) ?? "")")
        }else{
            //print("\(request.url!)"+"\(String(describing: request.httpMethod))")
        }
        done(.success(request))
    } catch {
        done(.failure(MoyaError.underlying(error, nil)))
    }
}

/// NetworkActivityPlugin插件用来监听网络请求
private let networkPlugin = NetworkActivityPlugin.init { (changeType, targetType) in
    
    //print("networkPlugin \(changeType)")
    //targetType 是当前请求的基本信息
    switch(changeType){
    case .began:
        //print("开始请求网络")
        SVProgressHUD.show()
        break
        
    case .ended:
        //print("结束")
        SVProgressHUD.dismiss()
        break
    }
}
