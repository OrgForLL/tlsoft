function EventTarget() {
    this.handlers = {};
}
EventTarget.prototype = {
    constructor: EventTarget,
    addEvent: function(type, handler) {
        if (typeof this.handlers[type] == 'undefined') {
            this.handlers[type] = [];
        }
        this.handlers[type].push(handler);
    },
    fireEvent: function(event) {
        if (!event.target) {
            event.target = this;
        }
        if (this.handlers[event.type]instanceof Array) {
            var handlers = this.handlers[event.type];
            for (var i = 0; i < handlers.length; i++) {
                handlers[i](event);
            }
        }
    },
    removeEvent: function(type, handler) {
        if (this.handlers[type]instanceof Array) {
            var handlers = this.handlers[type];
            for (var i = 0; i < handlers.length; i++) {
                if (handlers[i] == handler) {
                    break;
                }
            }
            handlers.splice(i, 1);
        }
    }
};
function ArrayList() {
    this.arr = [],
    this.size = function() {
        return this.arr.length;
    }
    ,
    this.add = function() {
        if (arguments.length == 1) {
            this.arr.push(arguments[0]);
        } else if (arguments.length >= 2) {
            var deleteItem = this.arr[arguments[0]];
            this.arr.splice(arguments[0], 1, arguments[1], deleteItem)
        }
        return this;
    }
    ,
    this.get = function(index) {
        return this.arr[index];
    }
    ,
    this.removeIndex = function(index) {
        this.arr.splice(index, 1);
    }
    ,
    this.removeObj = function(obj) {
        this.removeIndex(this.indexOf(obj));
    }
    ,
    this.indexOf = function(obj) {
        for (var i = 0; i < this.arr.length; i++) {
            if (this.arr[i] === obj) {
                return i;
            }
            ;
        }
        return -1;
    }
    ,
    this.isEmpty = function() {
        return this.arr.length == 0;
    }
    ,
    this.clear = function() {
        this.arr = [];
    }
    ,
    this.contains = function(obj) {
        return this.indexOf(obj) != -1;
    }
}
;var INNOVRFIDReader = {
    createNew: function() {
        var yw = {};
        var FuncID = 0;
        var ws = null;
        var target = null;
        var SocketOpen = false;
        var bExitFromWait = false;
        var SplitChar = String.fromCharCode(65530);
        var Timer;
        var CList;
        var STimer;
        var evtData = '';
        var status;
        var flag=false;
        var timer=null;
        //
        yw.onResult = function(func) {
            target.addEvent("Result", func);
        }
        ;
        //
        var WSonOpen = function() {
            SocketOpen = true;
            status = ws.readyState;
            console.log("连接中状态码="+ws.readyState);
        };
        var WSonMessage = function(evt) {
            var text = '';
            console.log(evt.data);
            evtData = JSON.parse(evt.data);
            if(evtData.type == 1){
                text = '调用写入订单';
            }
            else if(evtData.type == 2){
                text = '调用写入样品';
            }
            else if(evtData.type == 3){
                text = '调用分样关联';
            }
            else if(evtData.type == 4){
                text = '调用接收样品';
            }
            else if(evtData.type == 5){
                text = '调用项目检测';
            }
            else if(evtData.type == 6){
                text = '调用项目赋码';
            }
            if (timer != null)
                clearTimeout(timer);
            var resultData = {
                type: "Result",
                ErrCode: 9001,                    
                Data:evt.data,
                status:status,
                text:text
            };
            if (target != null)
                target.fireEvent(resultData);
        };

        function doTimeout() {
            var resultData = {
                type: "Result",
                ErrCode: 9002,
                status:status,
                text:'当前已超时，没有信息返回'                    
                };
            if (target != null)
                target.fireEvent(resultData);
        }

        var WSonClose = function() {
            SocketOpen = false;
            status = ws.readyState;
            console.log("连接关闭状态码="+ws.readyState);
        };
        var WSonError = function() {
            alert("Error");
            status = ws.readyState;
            console.log("连接错误状态码="+ws.readyState);
        };
        
        var st = function() {
            if (CList.size() > 0) {
                ws.send(CList.get(0));
                CList.removeIndex(0);
            }
        };
        yw.TryConnect = function(wsip) {
            try {
                if ("WebSocket"in window) {
                    ws = new WebSocket(wsip);
                } else if ("MozWebSocket"in window) {
                    ws = new MozWebSocket(wsip);
                } else {
                    return false;
                }
                ws.onopen = WSonOpen;

                ws.onmessage = WSonMessage;
                ws.onclose = WSonClose;
                ws.onerror = WSonError;
                target = new EventTarget();
                CList = new ArrayList();
                STimer = setInterval(st, 100);
                return true;
            } catch (ex) {
                return false;
            }
        }
        ;
        yw.Disconnect = function() {
            clearInterval(Timer);
            clearInterval(STimer);
            if (ws != null)
                ws.close();
        }
        ;
        yw.getStatus = function(){
            return status;
        } 
        var sendtype = function(index,code){
            evtData = '';
            if(index==1){
                var message = {"type":"1"};
                
            }
            else if(index==2){
                var message = {"type":"2"};
            }
            else if(index==3){
                var message = {"type":"3"};
            }
            else if(index==4){
                var message = {"type":"4"};
            }
            else if(index==5){
                var message = {"type":"5"};
            }
            else if(index==6){
                var message = {"type":"6","code":code};
            }
            else {
                alert("error!");
                return;
            }
            
            var jsonmsg = JSON.stringify(message);
            var timer=null;
            ws.send(jsonmsg);
            
        };

        yw.writeOrder = function(){
               sendtype(1); 
               timer=setTimeout(doTimeout, 5000); 
        },
        yw.writeSample = function(){
                sendtype(2);
        },
        yw.relate = function(){
                sendtype(3);
        },
        yw.receiveSample = function(){
                sendtype(4);
        },
        yw.detection = function(){
                sendtype(5);
        },
        yw.coding = function(code){
                sendtype(6,code);
               
        }
      
        yw.Connected = function() {
            return SocketOpen;
        }
        ;
       
        return yw;
    }
};
