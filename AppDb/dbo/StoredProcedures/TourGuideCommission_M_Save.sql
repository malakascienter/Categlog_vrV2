
CREATE  PROCEDURE [dbo].[TourGuideCommission_M_Save]  
    @TxnJson VARCHAR(MAX),  
	@UserId    INT,  
	@PropertyId INT
AS  
BEGIN  TRY
BEGIN TRANSACTION
	SET NOCOUNT ON;

	DECLARE @AutoCodeId			INT
	SELECT	@AutoCodeId = Id
	FROM	AutoCodes
	WHERE	FileType = 'TGDOCNO'

	UPDATE LocationWiseAutoCodes
	SET NextNo = NextNo + 1
	WHERE	AutoCodeId = @AutoCodeId AND CompanyID = @PropertyId

	SELECT DocumentNo,TourGuideId,TotalAmount,Remark
	INTO #TempTxnHeader
	FROM OPENJSON(@TxnJson)
	WITH 
	(
		DocumentNo VARCHAR(20) '$.DocumentNo',
		TourGuideId INT '$.TourGuideId',
		TotalAmount DECIMAL(18,6) '$.TotalAmount',
		Remark VARCHAR(MAX) '$.Remark'
	)


	SELECT OrderNo,OrderDate,Outlet,PropertyId,OrderAmount,TourGuideCompaniesPer,TourGuidePer,TourGuideCompaniesId,CommissionAmount,BillType
	INTO #TempTxnDetails
	FROM OPENJSON(@TxnJson, '$.TxnDetails')
	WITH 
	(
		OrderNo VARCHAR(20) '$.OrderNo',
		OrderDate DATE '$.OrderDate',
		Outlet VARCHAR(5) '$.Outlet',
		PropertyId INT '$.PropertyId',
		OrderAmount DECIMAL(18,6) '$.OrderAmount',
		TourGuideCompaniesPer DECIMAL(18,6) '$.TourGuideCompaniesPer',
		TourGuidePer DECIMAL(18,6) '$.TourGuidePer',
		TourGuideCompaniesId INT '$.TourGuideCompaniesId',
		CommissionAmount DECIMAL(18,6) '$.CommissionAmount',
		BillType VARCHAR(15) '$.BillType'
	)



IF EXISTS
  (  
		SELECT T.* FROM #TempTxnDetails T INNER JOIN BillHeader B ON T.OrderNo = B.OrderNo AND T.OrderDate = B.OrderDate AND T.Outlet = B.Outlet AND T.PropertyId = B.PropertyId
		WHERE B.IsPaidCommission = 1 and T.BillType = 'FB'
		UNION ALL
		SELECT T.* FROM #TempTxnDetails T INNER JOIN POS_InvoiceHeader B ON T.OrderNo = B.InvoiceNo AND T.OrderDate = B.BusinessDate AND T.Outlet = B.LocationID AND T.PropertyId = B.CompanyID
		WHERE B.IsPaidCommission = 1 and T.BillType = 'RT'
  )
BEGIN

 
 RAISERROR ('Already Commission paid bill found.please check again!',16,1)   


END



IF EXISTS
  (  
		select * from [TourGuideTxnHeader] where DocumentNo in (select DocumentNo  from #TempTxnHeader) and PropertyId = @PropertyId
  )
BEGIN

 
 RAISERROR ('Document No already exist!',16,1)   

END



	INSERT INTO [dbo].[TourGuideTxnHeader]
           ([DocumentNo]
           ,[DocumentDate]
           ,[TourGuideId]
           ,[TotalAmount]
           ,[Remark]
           ,[PropertyId]
           ,[CreatedUserId]
           ,[CreatedDateTime])
   SELECT DocumentNo,
		  GETDATE(),
		  TourGuideId,
		  TotalAmount,
		  Remark,
		  @PropertyId,
		  @UserId,
		  GETDATE()
   FROM #TempTxnHeader

    DECLARE @TourGuideTxnHeaderId BIGINT
   	SET @TourGuideTxnHeaderId = SCOPE_IDENTITY()

	INSERT INTO [dbo].[TourGuideTxnDetails]
           ([TourGuideTxnHeaderId]
           ,[OrderNo]
           ,[OrderDate]
           ,[Outlet]
           ,[PropertyId]
           ,[OrderAmount]
           ,[TourGuideCompaniesPer]
           ,[TourGuidePer]
           ,[TourGuideCompaniesId]
           ,[CommissionAmount]
           ,[CreatedUserId]
           ,[CreatedDateTime])
    SELECT @TourGuideTxnHeaderId, 
		   OrderNo,
		   OrderDate,
		   Outlet,
		   @PropertyId,
		   OrderAmount,
		   TourGuideCompaniesPer,
		   TourGuidePer,
		   TourGuideCompaniesId,
		   CommissionAmount,
		   @UserId,
		   GETDATE()
	FROM #TempTxnDetails



	UPDATE B
	SET B.IsPaidCommission = 1
	FROM #TempTxnDetails T INNER JOIN BillHeader B ON T.OrderNo = B.OrderNo AND T.OrderDate = B.OrderDate AND T.Outlet = B.Outlet AND T.PropertyId = B.PropertyId
	WHERE  T.BillType = 'FB'

	UPDATE B
	SET B.IsPaidCommission = 1
	FROM #TempTxnDetails T INNER JOIN POS_InvoiceHeader B ON T.OrderNo = B.InvoiceNo AND T.OrderDate = B.BusinessDate AND T.Outlet = B.LocationID AND T.PropertyId = B.CompanyID
	WHERE  T.BillType = 'RT'


COMMIT TRANSACTION		
END TRY 
BEGIN CATCH
ROLLBACK TRANSACTION
	INSERT INTO GEN_ErrTable (ErrorNumber,ErrorSeverity,ErrorState,ErrorProcedure,ErrorLine,ErrorMessage)
    VALUES (ERROR_NUMBER(),ERROR_SEVERITY(),ERROR_STATE(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE())

	DECLARE  @ERRmsg VARCHAR(MAX) =ERROR_MESSAGE()
	RAISERROR(@ERRmsg,16,1)
END CATCH

GO

