﻿using BLL.Interfaces;
using DAL.Interfaces;
using DTO;

namespace BLL
{
    public class BLL_Users : ITF_BLL_Users
    {
        private ITF_DAL_Users _DAL_Users;
        public BLL_Users(ITF_DAL_Users dal_Users)
        {
            _DAL_Users = dal_Users;
        }

        public User GetUser_byID(int id)
        {
            return _DAL_Users.GetUser_byID(id);
        }

        public User Delete_User(int id)
        {
            return _DAL_Users.Delete_User(id);
        }

        public bool Update_User(User model)
        {
            return _DAL_Users.Update_User(model);
        }
        public bool Create_User(User2 model)
        {
            return _DAL_Users.Create_User(model);
        }
        public bool Deletes_User(List_User model)
        {
            return _DAL_Users.Deletes_User(model);
        }


        //Account
        public bool Update_Account(Account model)
        {
            return _DAL_Users.Update_Account(model);
        }
        public bool Deletes_Account(List_User model)
        {
            return _DAL_Users.Deletes_Account(model);
        }
        public Account Delete_Account(int id)
        {
            return _DAL_Users.Delete_Account(id);
        }
    }
}
