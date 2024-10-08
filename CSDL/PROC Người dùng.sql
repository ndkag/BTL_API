use DienDan_Vinfast
go
select*from Users
go
create proc sp_user_getid(@id int)
as
begin
select*from Users where ID_User = @id
end

go

alter proc sp_user_create(
    @AccountName VARCHAR(50),
    @Password VARCHAR(50),
    @FullName NVARCHAR(255),
    @Address NVARCHAR(255),
    @Sex NVARCHAR(20),
    @DateOfBirth DATE,
    @PhoneNumber CHAR(10),
    @Email VARCHAR(50),
    @Role VARCHAR(20),
    @Avatar nvARCHAR(max)
	)
AS
BEGIN
		SET NOCOUNT ON;
		DECLARE @ErrorMessage NVARCHAR(MAX);
		-- Kiểm tra xem tiêu đề đã tồn tại chưa
		IF EXISTS (SELECT 1 FROM Users WHERE AccountName = @AccountName)
		BEGIN
			SET @ErrorMessage = N'Tên tài khoản đã tồn tại, vui lòng nhập tài khoản khác.';
			-- Lưu thông báo lỗi vào biến cục bộ
			SELECT @ErrorMessage AS ErrorMessage;
			RETURN;
		END
		IF EXISTS (SELECT 1 FROM Users WHERE Email = @Email)
		BEGIN
			SET @ErrorMessage = N'Email đã tồn tại, vui lòng nhập email khác.';
			-- Lưu thông báo lỗi vào biến cục bộ
			SELECT @ErrorMessage AS ErrorMessage;
			RETURN;
		END

		--Thêm
		INSERT INTO Users (FullName, Address, Sex, DateOfBirth, PhoneNumber, Email,AccountName, Password, Role,Avatar)
		VALUES (@FullName, @Address, @Sex, @DateOfBirth, @PhoneNumber, @Email,@AccountName, @Password, @Role,@Avatar);
		
		-- Lưu thông báo lỗi (nếu có) vào biến cục bộ (trong trường hợp có lỗi sau khi thêm mới)
		SELECT NULL AS ErrorMessage;
END;
go

select*from Users
-----------------UPDATE
ALTER proc sp_user_update(
@ID_User int,
@FullName nvarchar(255),
@Address nvarchar(255),
@Sex nvarchar(20),
@DateOfBirth date,
@PhoneNumber char(10),
@Avatar nVARCHAR(max)
)

as
begin
update Users set FullName=@FullName, Address=@Address, Sex=@Sex, DateOfBirth=@DateOfBirth, PhoneNumber=@PhoneNumber, Avatar = @Avatar

where ID_User = @ID_User
end

exec sp_user_update @ID_User = 3, @FullName = 'Hi', @Address ='Hưng Yên',@Sex =N'Nữ',@DateOfBirth ='2023-12-18', @PhoneNumber='0987654321'
select*from Users
go



ALTER proc sp_user_update_all(
@ID_User int,
@Password varchar(50),
@FullName nvarchar(255),
@Address nvarchar(255),
@Sex nvarchar(20),
@DateOfBirth date,
@PhoneNumber char(10),
@Email varchar(50),
@Role varchar(10),
@Avatar nVARCHAR(max)
)
as
begin
		 SET NOCOUNT ON;
    DECLARE @ErrorMessage NVARCHAR(MAX);

    -- Kiểm tra xem đã tồn tại chưa (ngoại trừ bản ghi đang cập nhật)
    IF EXISTS (SELECT 1 FROM Users WHERE Email = @Email AND ID_User <> @ID_User)
    BEGIN
        SET @ErrorMessage = N'Email đã tồn tại, vui lòng email khác.';
        -- Lưu thông báo lỗi vào biến cục bộ
        SELECT @ErrorMessage AS ErrorMessage;
        RETURN;
    END

		update Users set FullName=@FullName, Address=@Address, Sex=@Sex, DateOfBirth=@DateOfBirth, PhoneNumber=@PhoneNumber, 
		 Password = @Password, Email = @Email, Role = @Role,Avatar = @Avatar
		where ID_User = @ID_User

		  -- Lưu thông báo lỗi (nếu có) vào biến cục bộ (trong trường hợp có lỗi sau khi cập nhật)
    SELECT NULL AS ErrorMessage;
end

go
create proc sp_user_delete(
@ID_User int)
as
begin
delete from Users
where ID_User = @ID_User
end


-------------------------------DELETES
drop PROCEDURE sp_user_deletes


CREATE PROCEDURE sp_user_deletes
(
    @list_json_ID_User varchar(255)
)
AS
BEGIN

	--Kiểm tra @list_json_ID_User có khác null ko, nếu khác thì thức hiện bước tiếp theo
    IF (@list_json_ID_User IS NOT NULL) 
    BEGIN
        -- Chèn dữ liệu vào bảng tạm 
        SELECT
            JSON_VALUE(p.value, '$.iD_User') AS iD_User
        INTO #Results 
        FROM OPENJSON(@list_json_ID_User) AS p;
		--OPENJSON giúp phần tích chuỗi json và lấy giá trị iduser
        -- Thực hiện xóa tài khoản dựa trên trường iduser
        DELETE A 
        FROM Users A
        INNER JOIN #Results R ON A.ID_User = R.iD_User;
		
        DROP TABLE #Results;
    END;
END;

--------------------------------------Tìm kiếm
select*from Users
drop PROCEDURE sp_user_search

exec sp_user_search @page_index = 1, @page_size =10, @Keywords = N''

alter PROCEDURE sp_user_search 
--CHuyển tham số đầu vào
    @page_index INT, 
    @page_size INT,
    @Keywords NVARCHAR(255)
AS
BEGIN
    DECLARE @RecordCount BIGINT;
	--Nếu khác 0 thì phân trang, ko thì trả ra ko phân trang
    BEGIN
        SET NOCOUNT ON;
		 -- Tạo bảng tạm #Results1, chèn dữ liệu người dùng được lấy từ bảng Users vào bảng tạm
        SELECT 
            ROW_NUMBER() OVER (ORDER BY ID_User DESC) AS RowNumber, 
            k.ID_User,
            k.FullName,
            k.Email,
            k.Address,
            k.DateOfBirth,
            k.Sex,
            k.PhoneNumber,
			k.Role,
			k.Avatar,
			k.AccountName,
			k.Password
        INTO #Results1
        FROM Users AS k
        WHERE  (
                    @Keywords = '' 
                    OR k.FullName LIKE N'%' + @Keywords + '%' 
                    OR k.Email LIKE N'%' + @Keywords + '%'
					OR k.PhoneNumber LIKE N'%' + @Keywords + '%'
					OR k.DateOfBirth LIKE N'%' + @Keywords + '%'
					OR k.Sex LIKE N'%' + @Keywords + '%'
					OR k.Address LIKE N'%' + @Keywords + '%'
					OR k.ID_User LIKE N'%' + @Keywords + '%'
					OR k.Role LIKE N'%' + @Keywords + '%'
					OR k.AccountName LIKE N'%' + @Keywords + '%'
					OR k.Password LIKE N'%' + @Keywords + '%'
                );                   
		--Đếm số bản ghi rồi tổng lại
        SELECT @RecordCount = COUNT(*)
        FROM #Results1;
		-- Nếu @pageSize khác 0, trả về kết quả phân trang. Ngược lại, trả về toàn bộ kết quả.
        SELECT 
            *, 
            @RecordCount AS RecordCount
        FROM #Results1
        WHERE 
            RowNumber BETWEEN (@page_index - 1) * @page_size + 1 AND (((@page_index - 1) * @page_size + 1) + @page_size) - 1
            OR @page_index = -1;

		--Xoá bảng tạm
        DROP TABLE #Results1; 
    END
   
END;
GO
