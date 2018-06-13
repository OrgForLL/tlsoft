using System;

    public class ResponseModel
    {
        private int _errcode;
        public int errcode
        {
            set { this._errcode = value; }
            get { return this._errcode; }
        }

        private object _data;
        public object data
        {
            set { this._data = value; }
            get { return this._data == null ? string.Empty : this._data; }
        }

        private string _errmsg = "";
        public string errmsg
        {
            set { this._errmsg = value; }
            get { return this._errmsg; }
        }

        public static ResponseModel setRes(int pcode, object pdata, string pmes)
        {
            ResponseModel res = new ResponseModel();
            res.errcode = pcode;
            res.data = pdata;
            res.errmsg = pmes;
            return res;
        }

        public static ResponseModel setRes(int pcode, object pdata)
        {
            return setRes(pcode, pdata, string.Empty);
        }

        public static ResponseModel setRes(int pcode, string pmes)
        {
            return setRes(pcode, string.Empty, pmes);
        }
    }

