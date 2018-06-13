using System;
using System.Collections.Generic;
using System.Drawing;
using System.Security.Cryptography;
using System.Text;
using System.Windows.Forms;

namespace App
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            string partnerid = "16434";
            string partnerKey = "7a6ee705-18cc-4614-b2bb-f8b6b0095e4e";
            List<string> lstParams = new List<string>();
            lstParams.Add("partnerid=" + partnerid);
            lstParams.Add("servicetype= LLWebApi_CL_GetPick");
            lstParams.Add("bizdata={\" BeginDate\": \" 2017-10-15 \",\"EndDate\":\"2017-10-30\"}");
            lstParams.Add("timestamp=" + string.Format("{0:yyyyMMddHHmmss}", DateTime.Now));
            lstParams.Add("nonce=" + System.Guid.NewGuid().ToString());
            string[] strParams = lstParams.ToArray();
            Array.Sort(strParams);     //参数名ASCII码从小到大排序（字典序）； 
            string origin = string.Join("&", strParams);
            origin = string.Concat(origin, partnerKey);
            MD5 md5 = new MD5CryptoServiceProvider();
            byte[] targetData = md5.ComputeHash(System.Text.Encoding.UTF8.GetBytes(origin));
            StringBuilder sign = new StringBuilder("");
            foreach (byte b in targetData)
            {
                sign.AppendFormat("{0:x2}", b);
            }
            this.textBox1.Text=sign.ToString();
        }

        private void button2_Click(object sender, EventArgs e)
        {
            Form f = new GraphicsAPI();
            f.Show();
        }

        private void button3_Click(object sender, EventArgs e)
        {
            Form f = new ScoketServer();
            f.Show();
        }
    }
}
