--SQL quan ly quan caphe


-- Lai -- 
--tao bang database 
CREATE DATABASE CoffeManagement
GO

--su dung database da tao la quanlyquancafe
USE CoffeManagement
GO

--tao cac table --

--Tao table tai khoan
CREATE TABLE Account
(
	UserName NVARCHAR(100) PRIMARY KEY,
	DisplayName NVARCHAR(100)NOT NULL DEFAULT N'Admin',
	PassWord NVARCHAR(100) NOT NULL DEFAULT 0,
	Type INT NOT NULL DEFAULT 0 --loai tai khoan -- 0:Quan ly -- 1:Nhan vien
)
GO

-- End -- 

-- Luan -- 
--Tao table ban nuoc
CREATE TABLE TableDrink
(
	id INT IDENTITY PRIMARY KEY,
	name NVARCHAR(100)NOT NULL DEFAULT N'chua dat ten',
	status NVARCHAR(100) NOT NULL DEFAULT N'Trong' --Status ban trong hoac co nguoi
)
GO

-- END -- 

-- Nguyen -- 
--tao table loai thuc uong
CREATE TABLE TypeDrink
(
	id INT IDENTITY PRIMARY KEY,
	name NVARCHAR(100)NOT NULL DEFAULT N'chua dat ten'
)
GO

--tao table thuc uong cua loai thuc uong nao
CREATE TABLE drink
(
	id INT IDENTITY PRIMARY KEY,
	name NVARCHAR(100)NOT NULL DEFAULT N'chua dat ten',
	idTypeDrink INT NOT NULL,
	price FLOAT NOT NULL DEFAULT 0
	
	FOREIGN KEY (idTypeDrink) REFERENCES dbo.TypeDrink(id)
)
GO

-- END -- 

-- Truc -- 
--tao table hoa don ban

CREATE TABLE Bill
(
	id INT IDENTITY PRIMARY KEY,
	DateCheckIn Date NOT NULL DEFAULT GETDATE(),
	DateCheckOut Date,
	idTable INT NOT NULL,
	status INT NOT NULL DEFAULT 0 --0:chua thanh toan , 1: da thanh toan
	
	FOREIGN KEY (idTable) REFERENCES dbo.TableDrink(id)
)
GO

ALTER TABLE Bill
ADD discount INT DEFAULT 0

GO


--tao table bao cao hoa don 
CREATE TABLE DrinkBill
(  
	id INT IDENTITY PRIMARY KEY,
	idBill INT NOT NULL,
	idDrink INT NOT NULL,
	count INT NOT NULL DEFAULT 0
	
	FOREIGN KEY (idBill) REFERENCES dbo.Bill(id),
	FOREIGN KEY (idDrink) REFERENCES dbo.Drink(id)
)
GO

-- END -- 

CREATE PROC SP_Ban
AS SELECT * FROM dbo.TableDrink
GO

EXEC SP_Ban

GO

--Them ban
CREATE PROC SP_themBan(@name NVARCHAR(100),@status NVARCHAR(100))
AS
BEGIN
	INSERT INTO TableDrink(name,status)
	VALUES(@name,@status)
END

EXEC SP_themBan N'ban 11','Trống'

GO
--Cap nhat ban
CREATE PROC SP_capnhatBan(@id INT,@name NVARCHAR(100),@status NVARCHAR(100))
AS
BEGIN
	UPDATE TableDrink
	SET name = @name,status = @status
	WHERE id = @id
END
GO

EXEC SP_capnhatBan 1,N'ban2','co nguoi'
GO

--Delete ban
CREATE PROC SP_xoaBan(@id INT)
AS
BEGIN
	DELETE FROM TableDrink
	WHERE id = @id
END
GO

EXEC SP_xoaBan 1
GO


-- lay danh sach tai khoan
CREATE PROC SP_Account
AS SELECT *FROM dbo.Account
GO
EXEC SP_Account
GO

--them tai khoan
CREATE PROC SP_themTaikhoan(@usernam NVARCHAR(100),@Displayname NVARCHAR(100),@Password NVARCHAR(100),@type INT)
AS
BEGIN
	INSERT INTO Account(UserName,DisplayName,PassWord,Type)
	VALUES(@usernam,@Displayname,@Password,@type)
END
GO
--cap nhat tai khoan
CREATE PROC SP_capnhatTaikhoan(@usernam NVARCHAR(100),@Displayname NVARCHAR(100),@Password NVARCHAR(100),@type INT)
AS
BEGIN
	UPDATE Account
	SET DisplayName = @Displayname,PassWord = @Password,Type =@type
	WHERE UserName = @usernam
END
GO

EXEC SP_capnhatTaikhoan N'lai',N'lainguyen',N'22',1
GO

EXEC SP_themTaikhoan N'lai','Admin','1',0
GO

--Delete taikhoan
CREATE PROC SP_xoaTaikhoan(@username NVARCHAR(100))
AS
BEGIN
	DELETE FROM Account
	WHERE UserName = @username
END
GO

EXEC SP_xoaTaikhoan N'lai'
GO

--lay danh sach loai thuc uong
CREATE PROC SP_LoaiDrink
AS SELECT *FROM dbo.TypeDrink
GO

EXEC SP_LoaiDrink
GO

--them loai thuc uong
CREATE PROC SP_themLoaidrink(@name NVARCHAR(100))
AS
BEGIN
	INSERT INTO TypeDrink(name)
	VALUES(@name)
END
GO

EXEC SP_themLoaidrink N'Capuchino'
GO
--cap nhat loai thuc uong
CREATE PROC SP_capnhatLoaidrink(@id INT,@name NVARCHAR(100))
AS
BEGIN
	UPDATE TypeDrink
	SET name = @name
	WHERE id = @id
END
GO

EXEC SP_capnhatLoaidrink 4,N'Capuchino'
GO

--delete loai thuc uong
CREATE PROC SP_xoaLoaidrink(@id INT)
AS
BEGIN
	DELETE FROM TypeDrink
	WHERE id = @id
END
GO

EXEC SP_xoaLoaidrink 1
GO

--lay danh sach thuc uong
CREATE PROC SP_listDrink
AS SELECT *FROM drink
GO

EXEC SP_listDrink
GO

--them thuc uong
CREAtE PROC SP_themDrink(@name NVARCHAR(100),@idloai INT,@price FLOAT)
AS
BEGIN
	INSERT INTO drink(name,idTypeDrink,price)
	VALUES(@name,@idloai,@price)
END
GO

EXEC SP_themDrink N'Sữa',4,22000
GO

INSERT INTO Bill(DateCheckIn,DateCheckOut,idTable,status)
VALUES (GETDATE(),GETDATE(),3,1)

GO

INSERT INTO DrinkBill(idBill,idDrink,count)
VALUES (6,4,1)
GO


SELECT d.name,db.count,d.price,d.price*db.count AS TotalPrice FROM dbo.DrinkBill AS db,dbo.drink AS d,dbo.Bill AS bi
WHERE db.idBill = bi.id AND db.idDrink = d.id AND status = 0 AND bi.idTable = 3

Go


--Lay danh sach drink theo id Typedrink
CREATE PROC SP_getDrinkbyIdTypeDrink(@id INT)
AS
BEGIN
SELECT * from drink WHERE idTypeDrink = @id
END
GO

EXEC SP_getDrinkbyIdTypeDrink 4

GO


--Them Hoa don theo ban
CREATE PROC SP_AddBill(@idTable INT)
AS
BEGIN
	INSERT INTO Bill(DateCheckIn,DateCheckOut,idTable,status,discount)
	VALUES (GETDATE() ,NULL,@idTable,0,0)
END
GO

--Them drinkbill theo idBill
CREATE PROC SP_AddDrinkBill (@idBill INT,@idDrink INT,@count INT)
AS
BEGIN
	DECLARE @exBillif INT
	DECLARE @drinkcout INT = 1
	SELECT @exBillif = id,@drinkcout = b.count 
	FROM DrinkBill AS b WHERE idBill = @idBill AND idDrink = @idDrink
	IF(@exBillif > 0)
	BEGIN
		DECLARE @newcount INT = @drinkcout + @count
		IF(@newcount > 0)
			UPDATE DrinkBill SET count = @drinkcout + @count WHERE idDrink = @idDrink
		ELSE
			DELETE DrinkBill WHERE idBill = @idBill AND idDrink = @idDrink
	END
	ELSE
	BEGIN
		INSERT INTO DrinkBill(idBill,idDrink,count)
		VALUES(@idBill,@idDrink,@count)
	END
END
GO

--Cap nhat Bill 
CREATE PROC SP_BillidTable(@id INT,@discount INT)
AS
BEGIN 
	UPDATE Bill SET status = 1, discount = @discount WHERE id = @id
END
GO
DELETE DrinkBill
DELETE Bill
GO
SELECT * FROM Bill
GO
--Update status cho table khi thêm drink
CREATE TRIGGER TG_updateDrinkBill 
ON dbo.DrinkBill FOR UPDATE, INSERT
AS
BEGIN
	DECLARE @idBill INT
	SELECT @idBill = idBill FROM inserted
	
	DECLARE @idTable INT
	SELECT @idTable = idTable FROM dbo.Bill WHERE id = @idBill AND status = 0
	
	UPDATE dbo.TableDrink SET status = N'Có người' WHERE id = @idTable
END
GO

--Update status cho table khi thanh toán
CREATE TRIGGER TG_updateBill
ON dbo.Bill FOR UPDATE
AS
BEGIN
	DECLARE @idBill INT
	SELECT @idBill = id FROM inserted
	
	DECLARE @idTable INT
	SELECT @idTable = idTable FROM dbo.Bill WHERE id = @idBill
	
	DECLARE @count INT = 0
	SELECT @count = COUNT(*) FROM dbo.Bill WHERE idTable = @idTable AND status = 0
	
	IF(@count = 0)
		UPDATE dbo.TableDrink SET status = N'Trống' WHERE id = @idTable
END
GO

--Chức năng chuyển bàn

CREATE PROC SP_chuyenBan(@idTable1 INT,@idTable2 INT)
AS
BEGIN
	DECLARE @idFirstBill INT
	DECLARE @idSecondBill INT
	
	DECLARE @statusFirstTable INT = 1
	DECLARE @statusSecondTable INT = 1
	
	SELECT @idSecondBill = id FROM dbo.Bill WHERE idTable = @idTable2 AND status = 0
	SELECT @idFirstBill = id FROM dbo.Bill WHERE idTable = @idTable1 AND status = 0
	
	IF(@idFirstBill IS NULL)
	BEGIN
		PRINT N'01'
		INSERT Bill(DateCheckIn ,DateCheckOut ,idTable ,status)
		VALUES(GETDATE() ,NULL ,@idTable1 ,0)
		SELECT @idFirstBill = MAX(id) FROM Bill WHERE idTable = @idTable1 AND status = 0
	END
	
	SELECT @statusFirstTable = COUNT(*) FROM DrinkBill WHERE idBill = @idFirstBill
	
	IF(@idSecondBill IS NULL)
	BEGIN
		PRINT N'02'
		INSERT Bill(DateCheckIn ,DateCheckOut ,idTable ,status)
		VALUES(GETDATE() ,NULL ,@idTable2 ,0)
		SELECT @idSecondBill = MAX(id) FROM Bill WHERE idTable = @idTable2 AND status = 0
		SET @statusSecondTable = 1
	END
	
	SELECT @statusSecondTable = COUNT(*) FROM DrinkBill WHERE idBill = @idSecondBill
	
	SELECT id INTO IDBillInfoTable FROM dbo.DrinkBill WHERE idBill = @idSecondBill
	
	UPDATE DrinkBill SET idBill = @idSecondBill WHERE idBill = @idFirstBill
	
	UPDATE DrinkBill SET idBill = @idFirstBill WHERE id IN (SELECT * FROM IDBillInfoTable)
	
	DROP TABLE IDBillInfoTable
	
	IF(@statusFirstTable = 0)
		UPDATE dbo.TableDrink SET status = N'Trống' WHERE id = @idTable2
	
	IF(@statusSecondTable = 0)
		UPDATE dbo.TableDrink SET status = N'Trống' WHERE id = @idTable1
END
GO

EXEC SP_chuyenBan 1, 2
GO
SELECT *FROM TableDrink

