
using System;
using System.Collections.Generic;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Threading;

namespace ConsoleCMD
{
    
    class Program
    {
        static bool ServiceStartFlag = false;
        static Socket socket;
        static Thread thread;
        private static byte[] result = new byte[1024];
        [ThreadStatic]
        static string str = "hehe";
        static void Main(string[] args)
        {

            string sql = @"hell{0},{1}";
            sql=string.Format(sql, "t", "a");
            sql += @"2{0}{1}";
            sql=string.Format(sql, "e", "f");
            Console.Write(sql);
            ////另一个线程只会修改自己TLS中的str变量
            //Thread th = new Thread(() => { str = "Mgen"; Display(); });
            //th.Start();
            //th.Join();
            //Display();

            socket = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
            IPHostEntry ieh = Dns.GetHostEntry("localhost");
            IPAddress localServerIP = ieh.AddressList[1];
            IPEndPoint localIPEndPoint = new IPEndPoint(localServerIP, 8080);

            socket.Bind(localIPEndPoint);
            socket.Listen(600);

            thread = new Thread(new ThreadStart(AcceptClient));
            thread.IsBackground = true;
            thread.Start();
            Console.WriteLine("服务启动" + localIPEndPoint.ToString());
            Console.ReadLine();            
        }
        static void Display()
        {
            Console.WriteLine("{0} {1}", Thread.CurrentThread.ManagedThreadId, str);
        }
        static void AcceptClient()
        {
            
            ServiceStartFlag = true;

            while (ServiceStartFlag)
            {
                try
                {
                    Socket newSocket = socket.Accept();
                    string onemessge = "<cross-domain-policy><allow-access-from domain=\"" + "*" + "\" to-ports=\"8080\"/></cross-domain-policy>\0";

                    byte[] tmpBytes = Encoding.UTF8.GetBytes(onemessge);
                    newSocket.Send(tmpBytes);

                    Thread newThread = new Thread(new ParameterizedThreadStart(ReadMsg));
                    newThread.IsBackground = true;
                    object obj = newSocket;
                    newThread.Start(obj);
                }
                catch (SocketException ex)
                {

                }
            }
        }

        static void ReadMsg(object obj)
        {
            Socket socket = (Socket)obj;

            while (ServiceStartFlag)
            {
                try
                {
                    if (socket.Connected)
                    {
                        int len = socket.Receive(result);
                        if (len > 0)
                        {
                            string sTime = DateTime.Now.ToShortTimeString();

                            string msg = sTime+string.Format(":接收客户端{0}消息{1}", socket.RemoteEndPoint.ToString(), Encoding.ASCII.GetString(result, 0, len));
                            Console.WriteLine(msg);
                            byte[] tmpBytes = Encoding.UTF8.GetBytes("Sended Sucessed!\0");

                            socket.Send(tmpBytes);
                        }


                    }
                }
                catch (SocketException ex)
                {
                    Console.WriteLine(ex.Message);
                }
            }
        }
    }
}
