-- =============================================
-- Author:		Nivesh
-- Create date: 2024-09-30
-- Description:	Insert Cashier Spot data
-- =============================================
-- SP_InsertCashierSpotCheck '<CashierHeader xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><Id>0</Id><PropertyID>1</PropertyID><LocationID>1</LocationID><SystemDate>0001-01-01T00:00:00</SystemDate><CashierValue>6285</CashierValue><UserID>4168</UserID><CashierDetail><CashierDetail><Id>0</Id><CashierHeaderID>0</CashierHeaderID><UserID>0</UserID><DTypeID>1</DTypeID><UnitValue>0</UnitValue><Nos>0</Nos><Value>5</Value><SysDate>0001-01-01T00:00:00</SysDate><PropertyID>0</PropertyID><LocationID>0</LocationID><SystemAmout>0</SystemAmout><BussinessDate>0001-01-01T00:00:00</BussinessDate><IsFirstApproval>false</IsFirstApproval><IsSecondApproval>false</IsSecondApproval><FirstApprovalUser>0</FirstApprovalUser><FirstApprovalDateTime>0001-01-01T00:00:00</FirstApprovalDateTime><SecondApprovalUser>0</SecondApprovalUser><SecondApprovalDateTime>0001-01-01T00:00:00</SecondApprovalDateTime></CashierDetail><CashierDetail><Id>0</Id><CashierHeaderID>0</CashierHeaderID><UserID>0</UserID><DTypeID>2</DTypeID><UnitValue>10</UnitValue><Nos>1</Nos><Value>10</Value><SysDate>0001-01-01T00:00:00</SysDate><PropertyID>0</PropertyID><LocationID>0</LocationID><SystemAmout>0</SystemAmout><BussinessDate>0001-01-01T00:00:00</BussinessDate><IsFirstApproval>false</IsFirstApproval><IsSecondApproval>false</IsSecondApproval><FirstApprovalUser>0</FirstApprovalUser><FirstApprovalDateTime>0001-01-01T00:00:00</FirstApprovalDateTime><SecondApprovalUser>0</SecondApprovalUser><SecondApprovalDateTime>0001-01-01T00:00:00</SecondApprovalDateTime></CashierDetail><CashierDetail><Id>0</Id><CashierHeaderID>0</CashierHeaderID><UserID>0</UserID><DTypeID>3</DTypeID><UnitValue>20</UnitValue><Nos>1</Nos><Value>20</Value><SysDate>0001-01-01T00:00:00</SysDate><PropertyID>0</PropertyID><LocationID>0</LocationID><SystemAmout>0</SystemAmout><BussinessDate>0001-01-01T00:00:00</BussinessDate><IsFirstApproval>false</IsFirstApproval><IsSecondApproval>false</IsSecondApproval><FirstApprovalUser>0</FirstApprovalUser><FirstApprovalDateTime>0001-01-01T00:00:00</FirstApprovalDateTime><SecondApprovalUser>0</SecondApprovalUser><SecondApprovalDateTime>0001-01-01T00:00:00</SecondApprovalDateTime></CashierDetail><CashierDetail><Id>0</Id><CashierHeaderID>0</CashierHeaderID><UserID>0</UserID><DTypeID>4</DTypeID><UnitValue>50</UnitValue><Nos>1</Nos><Value>50</Value><SysDate>0001-01-01T00:00:00</SysDate><PropertyID>0</PropertyID><LocationID>0</LocationID><SystemAmout>0</SystemAmout><BussinessDate>0001-01-01T00:00:00</BussinessDate><IsFirstApproval>false</IsFirstApproval><IsSecondApproval>false</IsSecondApproval><FirstApprovalUser>0</FirstApprovalUser><FirstApprovalDateTime>0001-01-01T00:00:00</FirstApprovalDateTime><SecondApprovalUser>0</SecondApprovalUser><SecondApprovalDateTime>0001-01-01T00:00:00</SecondApprovalDateTime></CashierDetail><CashierDetail><Id>0</Id><CashierHeaderID>0</CashierHeaderID><UserID>0</UserID><DTypeID>5</DTypeID><UnitValue>100</UnitValue><Nos>2</Nos><Value>200</Value><SysDate>0001-01-01T00:00:00</SysDate><PropertyID>0</PropertyID><LocationID>0</LocationID><SystemAmout>0</SystemAmout><BussinessDate>0001-01-01T00:00:00</BussinessDate><IsFirstApproval>false</IsFirstApproval><IsSecondApproval>false</IsSecondApproval><FirstApprovalUser>0</FirstApprovalUser><FirstApprovalDateTime>0001-01-01T00:00:00</FirstApprovalDateTime><SecondApprovalUser>0</SecondApprovalUser><SecondApprovalDateTime>0001-01-01T00:00:00</SecondApprovalDateTime></CashierDetail><CashierDetail><Id>0</Id><CashierHeaderID>0</CashierHeaderID><UserID>0</UserID><DTypeID>6</DTypeID><UnitValue>1000</UnitValue><Nos>1</Nos><Value>1000</Value><SysDate>0001-01-01T00:00:00</SysDate><PropertyID>0</PropertyID><LocationID>0</LocationID><SystemAmout>0</SystemAmout><BussinessDate>0001-01-01T00:00:00</BussinessDate><IsFirstApproval>false</IsFirstApproval><IsSecondApproval>false</IsSecondApproval><FirstApprovalUser>0</FirstApprovalUser><FirstApprovalDateTime>0001-01-01T00:00:00</FirstApprovalDateTime><SecondApprovalUser>0</SecondApprovalUser><SecondApprovalDateTime>0001-01-01T00:00:00</SecondApprovalDateTime></CashierDetail><CashierDetail><Id>0</Id><CashierHeaderID>0</CashierHeaderID><UserID>0</UserID><DTypeID>7</DTypeID><UnitValue>5000</UnitValue><Nos>1</Nos><Value>5000</Value><SysDate>0001-01-01T00:00:00</SysDate><PropertyID>0</PropertyID><LocationID>0</LocationID><SystemAmout>0</SystemAmout><BussinessDate>0001-01-01T00:00:00</BussinessDate><IsFirstApproval>false</IsFirstApproval><IsSecondApproval>false</IsSecondApproval><FirstApprovalUser>0</FirstApprovalUser><FirstApprovalDateTime>0001-01-01T00:00:00</FirstApprovalDateTime><SecondApprovalUser>0</SecondApprovalUser><SecondApprovalDateTime>0001-01-01T00:00:00</SecondApprovalDateTime></CashierDetail></CashierDetail></CashierHeader>'

CREATE PROCEDURE SP_InsertCashierSpotCheck
(@XMLDetails XML
 )
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	 INSERT tempBudgetAllocation
    (
        xmldata
    )
    SELECT @XMLDetails XMLDetails
	BEGIN TRY 
		BEGIN TRANSACTION;

		IF OBJECT_ID('tempdb..#CashierDetail') IS NOT NULL
		DROP TABLE #CashierDetail

			DECLARE @iDocID INT, @Id INT, @PropertyID INT, @LocationID INT, @SystemDate VARCHAR(50), @CashierValue DECIMAL(18,8), @UserID INT, @Remark VARCHAR(100)
          , @CashierHeaderID INT, @SystemAmount DECIMAL(18,8);
			EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails;

		SELECT 
			@Id =Id,
			@PropertyID =PropertyID,
			@LocationID =LocationID,
			@SystemDate =GETDATE(),
			@CashierValue =CashierValue,
			@UserID=UserID,
			@Remark =Remark
		FROM
        OPENXML(@iDocID, '/CashierHeader', 2)
        WITH
        (
			Id INT,
			PropertyID INT,
			LocationID INT,
			SystemDate VARCHAR(50),
			CashierValue DECIMAL(18,8),
			UserID INT,
			Remark VARCHAR(100)
        );

		IF(@PropertyID = 0 OR @PropertyID IS NULL)
		BEGIN
			RAISERROR('Property ID Invalid',16,1)
			ROLLBACK TRANSACTION
		END

		IF(@LocationID = 0 OR @LocationID IS NULL)
		BEGIN
			RAISERROR('Location ID Invalid',16,1)
			ROLLBACK TRANSACTION
		END

		IF(@UserID = 0 OR @UserID IS NULL)
		BEGIN
			RAISERROR('User ID Invalid',16,1)
			ROLLBACK TRANSACTION
		END

		SELECT @SystemAmount = Balance FROM BudgetAllocation WHERE LocationID = @LocationID;

		IF NOT EXISTS(SELECT 1 FROM BudgetAllocation WHERE LocationID = @LocationID)
		BEGIN
		DECLARE @Message VARCHAR(100) =''
		SELECT @Message = Name FROM Locations WHERE Id = @LocationID;
		SET @Message = 'Allocate Budget for this location '+ @Message
			RAISERROR(@Message,16,1)
			ROLLBACK TRANSACTION
		END

		CREATE TABLE #CashierDetail
		(
			DTypeID INT,
			UnitValue DECIMAL(18,8),
			Nos INT,
			Value DECIMAL(18,8)
		)

		INSERT INTO #CashierDetail
		(
			DTypeID ,
			UnitValue ,
			Nos ,
			Value 
		)
		SELECT
			DTypeID ,
			UnitValue ,
			Nos ,
			Value 
		FROM
		OPENXML(@iDocID, '/CashierHeader/CashierDetail/CashierDetail', 2)
        WITH
        (
			DTypeID INT,
			UnitValue DECIMAL(18,8),
			Nos INT,
			Value DECIMAL(18,8)
        );

		IF NOT EXISTS (SELECT 1 FROM #CashierDetail)
		BEGIN
			RAISERROR('Please Provide Cashier Details',16,1)
			ROLLBACK TRANSACTION
		END

		INSERT INTO
		CashierHeader (PropertyID,LocationID,SystemDate,CashierValue,UserID,Remark,SystemAmount)
		VALUES(@PropertyID,@LocationID,@SystemDate, @CashierValue,@UserID, @Remark,ISNULL(@SystemAmount,0))

		SET @CashierHeaderID = SCOPE_IDENTITY()

		INSERT INTO CashierDetail (CashierHeaderID,UserID,DTypeID,Nos,Value,SysDate,PropertyID,LocationID,SystemAmout,BussinessDate,IsFirstApproval,
		IsSecondApproval,FirstApprovalRemark,SecondApprovalRemark,FirstApprovalUser,FirstApprovalDateTime,SecondApprovalUser,SecondApprovalDateTime)
		SELECT @CashierHeaderID,@UserID,DTypeID,Nos,Value,@SystemDate, @PropertyID, @LocationID,ISNULL(@SystemAmount,0), GETDATE(),0,0,'','',0,GETDATE(),0,GETDATE()
		FROM
		#CashierDetail

		IF OBJECT_ID('tempdb..#CashierDetail') IS NOT NULL
		DROP TABLE #CashierDetail

		COMMIT TRANSACTION;

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT>0
		ROLLBACK TRANSACTION
			DECLARE @ErrorMessage NVARCHAR(4000);  
			DECLARE @ErrorSeverity INT;  
			DECLARE @ErrorState INT;  

			SELECT   
			@ErrorMessage = ERROR_MESSAGE(),  
			@ErrorSeverity = ERROR_SEVERITY(),  
			@ErrorState = ERROR_STATE(); 
			RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
	END CATCH;
END

GO

