using System;
using System.Collections.Generic;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Threading;
using System.Windows.Forms;
namespace App
{
    public partial class ScoketServer : Form
    {
        static bool ServiceStartFlag = false;
        static Socket socketWatch;
        
        static Thread AcceptSocketThread;
        public Dictionary<string, Socket> clientList;
        private Dictionary<string, Thread> clientThread = new Dictionary<string, Thread>();//线程字典,每新增一个连接就添加一条线程
        //这个是指消息结束符的长度，此处为\r\n
        public string terminateString = "\0";
        public int receiveBufferSize = 1024;
        //定义delegate以便Invoke时使用   
        private delegate void addListDelegate(string key,string tag);
        private delegate void oneDelegate(string key);
        public ScoketServer()
        {
            InitializeComponent();
        }

        private void ScoketServer_Load(object sender, EventArgs e)
        {
            clientList = new Dictionary<string, Socket>();
            ColumnHeader ch = new ColumnHeader();
            this.listView1.View = View.Details;
            ch.Text = "列标题1";   //设置列标题
            ch.Width = 256;    //设置列宽度
            ch.TextAlign = HorizontalAlignment.Left;   //设置列的对齐方式
            this.listView1.Columns.Add(ch);    //将列头添加到ListView控件
        }

        private void InitScoket()
        {
            ServiceStartFlag = true;
            socketWatch = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
            IPHostEntry ieh = Dns.GetHostEntry("localhost");
            IPAddress localServerIP = ieh.AddressList[1];
            IPEndPoint localIPEndPoint = new IPEndPoint(localServerIP, 8080);

            socketWatch.Bind(localIPEndPoint);
            //开始监听:设置最大可以同时连接多少个请求
            socketWatch.Listen(600);
            //实例化回调
            
            this.txt_Log.AppendText("服务启动:" + localIPEndPoint.ToString() + "\r\n");

            AcceptSocketThread = new Thread(new ParameterizedThreadStart(AcceptClient));
            AcceptSocketThread.IsBackground = true;
            AcceptSocketThread.Start(socketWatch);
        }

        private void AcceptClient(object obj)
        {
            Socket socketWatch = obj as Socket;
            while (ServiceStartFlag)
            {
                try
                {
                    Socket sokConnection = socketWatch.Accept();

                    string key = sokConnection.RemoteEndPoint.ToString();
                    clientList.Add(key, sokConnection);
                    this.BeginInvoke(new addListDelegate(addList), key,"");

                    Thread threadReceive = new Thread(new ParameterizedThreadStart(ReadMsg));
                    threadReceive.IsBackground = true;
                    threadReceive.Start(sokConnection);
                    //把线程及客户连接加入字典
                    clientThread.Add(key, threadReceive);
                }
                catch (SocketException ex)
                {
                    this.BeginInvoke(new oneDelegate(logAdd), ex.Message + ex.StackTrace);
                }
            }
        }

        private void ReadMsg(object obj)
        {
            Socket socketSend = (Socket)obj;           

            while (ServiceStartFlag)
            {
                try
                {
                    if (socketSend.Connected)
                    {

                        byte[] buffer = new byte[receiveBufferSize];  //buffer大小，此处为1024
                        int receivedSize = socketSend.Receive(buffer);

                        string rawMsg = Encoding.UTF8.GetString(buffer, 0, receivedSize);
                        StringBuilder sb = new StringBuilder();
                        int rnFixLength = terminateString.Length;   //这个是指消息结束符的长度，此处为\r\n
                        for (int i = 0; i < rawMsg.Length;)               //遍历接收到的整个buffer文本
                        {
                            if (i <= rawMsg.Length - rnFixLength)
                            {
                                if (rawMsg.Substring(i, rnFixLength) != terminateString)//非消息结束符，则加入sb
                                {
                                    sb.Append(rawMsg[i]);
                                    i++;
                                }
                                else
                                {
                                    //this.OnNewMessageReceived(sb.ToString());//找到了消息结束符，触发消息接收完成事件
                                    //sb.Clear();
                                    i += rnFixLength;
                                }
                            }
                            else
                            {
                                sb.Append(rawMsg[i]);
                                i++;
                            }
                        }
                        if (sb.Length > 0)
                        {
                            string sTime = DateTime.Now.ToString(); ;
                            string msg = sTime + "," + "from:";
                            msg += socketSend.RemoteEndPoint.ToString() + ",Message:" + sb.ToString();

                            //连接开始的时候客户端id是空串
                            //第一次连接的时候会将客户端id传过来,这里需求将id和scoket绑定在一起
                            string key = socketSend.RemoteEndPoint.ToString();
                            this.BeginInvoke(new addListDelegate(addList), key, sb.ToString());
                            this.BeginInvoke(new oneDelegate(logAdd), msg);
                            byte[] tmpBytes;
                            if (string.Compare(sb.ToString(), "<policy-file-request/>", true) == 0)
                            {//如果是flash连接,会发送2个连接,第一个会是一个权限认证,需要发回认证
                                tmpBytes = Encoding.UTF8.GetBytes("<cross-domain-policy><allow-access-from domain=\"" + "*" + "\" to-ports=\"8080\"/></cross-domain-policy>\0");
                                socketSend.Send(tmpBytes);
                            }
                            tmpBytes = Encoding.UTF8.GetBytes("Sended Sucessed!"+ sb.ToString() + "\0");
                            socketSend.Send(tmpBytes);

                            

                        }
                    }
                }
                catch (SocketException ex)
                {
                    Console.WriteLine(ex.Message);
                }
            }
        }

        public void logAdd(string key)
        {
            this.txt_Log.AppendText(key + "\r\n");
        }
        private void addList(string key,string msg)
        {
            this.listView1.BeginUpdate();   //数据更新，UI暂时挂起，直到EndUpdate绘制控件，可以有效避免闪烁并大大提高加载速度
            if (string.IsNullOrEmpty(msg))
            {//接收到请求后
                ListViewItem lvi = new ListViewItem();                
                lvi.Text = key;                
                this.listView1.Items.Add(lvi);
            }else
            {
                if (string.Compare(msg, "<policy-file-request/>", true) == 0)
                {//flash的安全谁

                    for (int j = 0; j < listView1.Items.Count; j++)
                    {
                        if (listView1.Items[j].Text.Equals(key))
                        {
                            listView1.Items.Remove(listView1.Items[j]);
                            j--;
                        }
                    }
                }               
            }
            this.listView1.EndUpdate();  //结束数据处理，UI界面一次性绘制。
        }

        private void SetValue(string strValue)
        {
            this.txt_Log.AppendText(strValue + "\r\n");
        }

        private void button3_Click(object sender, EventArgs e)
        {
            InitScoket();
        }

        private void button2_Click(object sender, EventArgs e)
        {

            lock (clientList)
            {
                foreach (var item in clientList)
                {
                    item.Value.Close();//关闭每一个连接
                }
                clientList.Clear();//清除字典
            }
            lock (clientThread)
            {
                foreach (var item in clientThread)
                {
                    item.Value.Abort();//停止线程
                }
                clientThread.Clear();
            }
            ServiceStartFlag = false;
            //ServerSocket.Shutdown(SocketShutdown.Both);//服务端不能主动关闭连接,需要把监听到的连接逐个关闭
            if (socketWatch != null)
                socketWatch.Close();
            //终止线程
            AcceptSocketThread.Abort();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            ListView.SelectedListViewItemCollection s = this.listView1.SelectedItems;
            if (s.Count == 0)
            {
                MessageBox.Show("选中一个连接");
            }
            else
            {
                byte[] tmpBytes = Encoding.UTF8.GetBytes(this.sendText.Text + "\0");
                if (clientList[s[0].Text].Connected)
                {
                    clientList[s[0].Text].Send(tmpBytes);
                }else
                {
                    MessageBox.Show("已断开");
                }
            }
        }

        private void test(Socket client,EndPoint anEndPoint)
        {
            client.Connect(anEndPoint);

            // This is how you can determine whether a socket is still connected.
            bool blockingState = client.Blocking;
            try
            {
                byte[] tmp = new byte[1];

                client.Blocking = false;
                client.Send(tmp, 0, 0);
                Console.WriteLine("Connected!");
            }
            catch (SocketException e)
            {
                // 10035 == WSAEWOULDBLOCK
                if (e.NativeErrorCode.Equals(10035))
                    Console.WriteLine("Still Connected, but the Send would block");
                else
                {
                    Console.WriteLine("Disconnected: error code {0}!", e.NativeErrorCode);
                }
            }
            finally
            {
                client.Blocking = blockingState;
            }
        }

    }
}
