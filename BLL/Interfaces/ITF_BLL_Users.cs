﻿using DTO;

namespace BLL.Interfaces
{

    public partial interface ITF_BLL_Users
    {
        User GetUser_byID(int id);

        bool Create_User(User model);

        bool Update_User(User model);
    }


}
