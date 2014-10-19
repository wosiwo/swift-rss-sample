//
//  ViewController.swift
//  RSSReader
//
//  Created by susieyy on 2014/06/03.
//  Copyright (c) 2014年 susieyy. All rights reserved.
//
import UIKit

class ViewController: UITableViewController, MWFeedParserDelegate { //
    
    var items = [MWFeedItem]()
    var urlMap = ["a":1]
    var newPage = 0
    var oldPage = 1
    var currentPage = 1
    var addType = 1     //1:append 2:insert
    var url = "http://onceme.me/rss";
    
//    init(link:String){
//        super.init()
//        self.url = link
//    }
//    required init(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    func dataInit(){
        println("data init")
        self.items = [MWFeedItem]()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        sideMenu = ENSideMenu(sourceView: self.view, menuTableViewController: MyMenuTableViewController(), menuPosition:.Left)
        
        // make navigation bar showing over side menu
//        view.bringSubviewToFront(navigationBar)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        request(self.url)
        
        self.setupRefresh()
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func request(link:String) {
        println(link)
        // http://www.infoq.com/cn/feed/
        var urlStr = link+"?p=\(currentPage)"
        
        let URL = NSURL(string:urlStr ) //
        let feedParser = MWFeedParser(feedURL: URL);
        feedParser.delegate = self
        feedParser.parse()
    }
    
    func setupRefresh(){
        self.tableView.addHeaderWithCallback({
            self.currentPage = self.newPage
            self.addType = 2
            let delayInSeconds:Int64 =  100  * 2
            
            
            var popTime:dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW,delayInSeconds)
            dispatch_after(popTime, dispatch_get_main_queue(), {
                self.request(self.url)
                self.tableView.reloadData()
                self.tableView.headerEndRefreshing()
            })
            
        })
        
        
        self.tableView.addFooterWithCallback({
            self.currentPage = ++self.oldPage
            self.addType = 1
            let delayInSeconds:Int64 = 100 * 2
            var popTime:dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW,delayInSeconds)
            dispatch_after(popTime, dispatch_get_main_queue(), {
                self.request(self.url)
                self.tableView.reloadData()
                self.tableView.footerEndRefreshing()
                
                //self.tableView.setFooterHidden(true)
            })
        })
    }
    
    
    func feedParserDidStart(parser: MWFeedParser) {
        println(1)
        SVProgressHUD.show()
        println(2)
        
    }

    func feedParserDidFinish(parser: MWFeedParser) {
        println(3)
        SVProgressHUD.dismiss()
        println(4)
        self.tableView.reloadData()
        println(5)
    }
    
    
    func feedParser(parser: MWFeedParser, didParseFeedInfo info: MWFeedInfo) {
        println(info.title)
        self.title = info.title
    }
    
    func feedParser(parser: MWFeedParser, didParseFeedItem item: MWFeedItem) {
        println(item.title)
        if let airportName = self.urlMap[item.title.md5] {
            
        }else{
            self.urlMap[item.title.md5] = (1+self.items.count)
            println(self.items.count)
            if 1==self.addType{
                self.items.append(item)
            }else{
                self.items.insert(item,atIndex:0)
            }
                    
        }
        
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "FeedCell")
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item = self.items[indexPath.row] as MWFeedItem
        let con = KINWebBrowserViewController()
        let URL = NSURL(string: item.link)
        con.loadURL(URL)
        self.navigationController!.pushViewController(con, animated: true)
    }
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let item = self.items[indexPath.row] as MWFeedItem
        cell.textLabel!.text = item.title
        cell.textLabel!.font = UIFont.systemFontOfSize(14.0)
        cell.textLabel!.numberOfLines = 0
        
        let projectURL = item.link.componentsSeparatedByString("?")[0]
        let imgURL: NSURL = NSURL(string: projectURL + "/cover_image?style=200x200#")
        cell.imageView!.contentMode = UIViewContentMode.ScaleAspectFit
        cell.imageView!.setImageWithURL(imgURL, placeholderImage: UIImage(named: "logo.png"))
    }

}

extension String  {
    var md5: String! {
        let str = self.cStringUsingEncoding(NSUTF8StringEncoding)
        let strLen = CC_LONG(self.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.alloc(digestLen)
        
        CC_MD5(str!, strLen, result)
        
        var hash = NSMutableString()
        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i])
        }
        
        result.destroy()
        
        return String(format: hash)
    }
}

