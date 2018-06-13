using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace App
{
    public partial class GraphicsAPI : Form
    {
        public GraphicsAPI()
        {
            InitializeComponent();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            System.Drawing.Graphics graphics = this.CreateGraphics();
            // 红色笔  
            Pen pen = new Pen(Color.Red, 5);
            Rectangle rect = new Rectangle(0, 0, 200, 50);
            // 用红色笔画矩形  
            graphics.DrawRectangle(pen, rect);
            Font wkTitleBlod = new Font("微软雅黑", 17, FontStyle.Bold);
            Brush wkBrush = new SolidBrush(Color.Black);
            graphics.DrawString("hello", wkTitleBlod, wkBrush, new Point(0, 0));
            graphics.TranslateTransform(300, 50);
            graphics.RotateTransform(180);
            graphics.DrawString("hello", wkTitleBlod, wkBrush, new Point(0, 0));
            // 蓝色笔  
            pen.Color = Color.Blue;
            // 用蓝色笔重新画平移之后的矩形  
            graphics.DrawRectangle(pen, rect);
            graphics.Dispose();
            pen.Dispose();
        }
    }
}
