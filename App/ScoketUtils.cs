﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Sockets;
using System.Text;

namespace App
{
    public class ScoketUtils
    {
        /// <summary>
        /// Close the socket safely.
        /// </summary>
        /// <param name="socket">The socket.</param>
        public static void SafeClose(Socket socket)
        {
            if (socket == null)
                return;

            if (!socket.Connected)
                return;

            try
            {
                socket.Shutdown(SocketShutdown.Both);
            }
            catch
            {
            }

            try
            {
                socket.Close();
            }
            catch
            {
            }
        }

        /// <summary>
        /// Sends the data.
        /// </summary>
        /// <param name="client">The client.</param>
        /// <param name="data">The data.</param>
        public static void SendData(Socket client, byte[] data)
        {
            SendData(client, data, 0, data.Length);
        }

        /// <summary>
        /// Sends the data.
        /// </summary>
        /// <param name="client">The client.</param>
        /// <param name="data">The data.</param>
        /// <param name="offset">The offset.</param>
        /// <param name="length">The length.</param>
        public static void SendData(Socket client, byte[] data, int offset, int length)
        {
            int sent = 0;
            int thisSent = 0;

            while ((length - sent) > 0)
            {
                thisSent = client.Send(data, offset + sent, length - sent, SocketFlags.None);
                sent += thisSent;
            }
        }
    }

}
