-- =============================================
-- Author:		Vinuki
-- Create date: 24.06.2024
-- Description:	Get All Details ForPOApproval WithLocation Filteration
--SP_GetAllPOapprovalsWithLocation 8210,1,4,'s',0,0,4168
-- =============================================
CREATE PROCEDURE SP_GetAllPOapprovalsWithLocation (
@userprofileid int ,
@PropertyID int , 
@LocationIDN int,
@type varchar(5),
@PoHeaderID	VARCHAR(100) = NULL,
@PoDetailID	VARCHAR(100) = NULL,
@TransferUser int)

AS
BEGIN

BEGIN TRY 
Declare @T1 varchar(max),
			@T2 varchar(max),
			@T3 varchar(max),
			@Sql varchar(max),
			@IsPoModificationComponent bit

			IF(@UserProfileId = 0)
			BEGIN
				RAISERROR('User ID Invalid, Please Log In Again',16,1)
				ROLLBACK TRANSACTION
			END
		
			IF OBJECT_ID('tempdb..#PENINGPOHEADER') IS NOT NULL
			DROP TABLE #PENINGPOHEADER

			create table #PENINGPOHEADER (POHeaderID int ,ApprovalTypeID int,ReqUserProfId int, ReqUserProf varchar(max),POValue DECIMAL(18,2), TransactionID INT)

			insert into #PENINGPOHEADER 
			--EXEC [dbo].[SP_SelectPeningPOApprovalForUser]  @UserProfileId, @PropertyID
			EXEC [dbo].[SP_SelectPeningPOApprovalForUserForTransactionApproval]  @UserProfileId, @PropertyID,@TransferUser

			

			set @IsPoModificationComponent = 
			(select IsPoModificationComponent from Companies where CompanyID = @PropertyID) 

			 
	IF(@Type = 'S')

		BEGIN
			SELECT     
			h.Id SN,
			app.Id AS ApprovalTypeID,
			app.ApprovalTypeName [Approvel], 
			l.Name Location,
			#PENINGPOHEADER.ReqUserProfId,
			#PENINGPOHEADER.ReqUserProf,
			#PENINGPOHEADER.POValue,
			PoNo, 
			DocumentDate,
			s.Name Supplier, 
			h.Remarks,
			#PENINGPOHEADER.TransactionID,
			app.ApprovalTypename,
			[dbo].[GET_LastApprovedUser](2,h.Id) AS LastApprovedUser,
			C.Name AS CompanyName,
			h.TaxTotal,
			apl.seqid as SeqID,
			CASE 
            WHEN apl.seqid = 1 
			--and h.IsDirectPo = 0
			and C.isPOPrepModification = 1  THEN 1
            ELSE 0
        END as SeqIDStatus
		FROM         dbo.PoHeaders h
		inner join  #PENINGPOHEADER on #PENINGPOHEADER.POHeaderID = h.Id
		inner join dbo.Locations l on l.Id=h.locationId
		inner join dbo.Suppliers s on h.SupplierID=s.ID 
		inner join dbo.ApprovalTypes app on app.Id= #PENINGPOHEADER.ApprovalTypeID
		inner join dbo.ApprovalLogs apl on apl.TransactionHeaderID = h.Id and apl.ApprovalUserID = @UserProfileId and apl.TransactionID = 2 -- added by vinuki 31.05.2024 
		inner join Companies C on C.CompanyID = h.PropertyID
		WHERE     (h.PropertyID = CASE WHEN @PropertyID = -999 THEN h.PropertyID ELSE @PropertyID END) 
		and h.IsApproved=0 and DocumentStatus <> 'X' 
		and l.id = @LocationIDN
		ORDER BY h.createddate DESC 
		--AND h.Id = case when @PoHeaderID IS null then h.Id  else @PoHeaderID end 
		
		END


		

	IF(@Type = 'C')
	BEGIN
		DECLARE @IsCentralLogin BIT
		SELECT @IsCentralLogin = IsCentralLogin FROM Companies
		WHERE CompanyID =  CASE WHEN @PropertyID = -999 THEN CompanyID ELSE @PropertyID END
		IF(@IsCentralLogin = 1)
		BEGIN
			SELECT H.ID SN,
			   S.Name AS SupplierName,
			   H.SupplierID AS SupplierId,
		       H.PoNo ,
		       U.UserName ReqUserProf,
			   l.Name Location, 
			   h.DocumentDate ,
			   H.NetTotal POValue,
				   ISNULL(H.Remarks,'') Remarks,
				   C.name CompanyName
			FROM dbo.PoHeaders H
			INNER JOIN [dbo].[CentralUsers] U ON u.Id = H.UserProfileID
			INNER JOIN suppliers S ON S.ID = H.SupplierID
			INNER JOIN dbo.Locations L ON L.Id = H.LocationID
			INNER JOIN Companies C ON C.CompanyID = H.PropertyID
			WHERE DocumentStatus <> 'C' AND DocumentStatus <> 'X' 
			AND H.PropertyID = CASE WHEN @PropertyID = -999 THEN H.PropertyID ELSE @PropertyID END
		END
		ELSE
		BEGIN
			SELECT H.ID SN,
		       H.PoNo ,
		       U.UserName ReqUserProf,
			   l.Name Location, 
			   h.DocumentDate ,
			   H.NetTotal POValue,
			   ISNULL(H.Remarks,'') Remarks,
			   C.Name CompanyName
			FROM dbo.PoHeaders H
			INNER JOIN dbo.UserMasters U ON u.Id = H.UserProfileID
			INNER JOIN dbo.Locations L ON L.Id = H.LocationID
			INNER JOIN Companies C ON C.CompanyID = H.PropertyID
			WHERE DocumentStatus <> 'C' AND DocumentStatus <> 'X' 
			AND H.PropertyID = CASE WHEN @PropertyID = -999 THEN H.PropertyID ELSE @PropertyID END
		END

	END


	ELSE IF(@Type = 'D')
		BEGIN

		DECLARE @PoHeaderIDtemp INT, @LocationID int
			SET @PoHeaderIDtemp = CAST (@PoHeaderID AS INT)
			
		
		DECLARE @tblRequestHeader AS TABLE (Id INT IDENTITY(1,1),PoDetailID INT,PoHeaderID INT,StockItemID INT,StockItemCode INT,
		ItemName VARCHAR(max),UnitCode int,UnitName VARCHAR(max), StockInHand  DECIMAL(18,2) ,RequestedQuantity float ,
		ApprovedQuantity float ,ReceivedQuantity float,Remarks VARCHAR(max),UnitPrice DECIMAL(18,2),flag INT,
		RequestHeaderID INT,RequestionQty float, LocationID int, Tax DECIMAL(18,2) )

		INSERT INTO @tblRequestHeader
				(
				  PoDetailID ,
				  PoHeaderID ,
				  StockItemID ,
				  StockItemCode ,
				  ItemName ,
				  UnitCode ,
				  UnitName ,
				  RequestedQuantity ,
				  ApprovedQuantity,
				  ReceivedQuantity ,
				  Remarks ,
				  UnitPrice,
				  flag,
				  RequestHeaderID,
				  RequestionQty,
				  StockInHand,
				  LocationID,
				  Tax
				)
		SELECT	DISTINCT	
			d.Id AS PoDetailID,
			d.PoHeaderID, 
			PWR.StockItemID,  
			i.StockItemID AS StockItemCode,			
			ih.Name AS ItemName,
			d.UnitID AS UnitCode, 
	        u.Name  AS UnitName,
			d.RequestedQuantity, 
			d.ApprovedQuantity, 
			ReceivedQuantity, 
			d.Remarks,
			d.UnitPrice - case when DiscountValue<> 0 THEN DiscountValue ELSE (d.UnitPrice *DiscountPercentage /100) END  ,
			RH.flag,
			PWR.RequestHeaderID,
			PWR.RequestionQty,
			--dbo.GetStockInHand(h.PropertyID,h.LocationID,d.StockItemID),
			 dbo.[FN_GetStockInHand_Reatils](h.PropertyID,h.LocationID,d.StockItemID),
			h.LocationID,
			h.TaxTotal

		FROM         dbo.PoDetails d
			inner join	dbo.PoHeaders h on h.Id = d.PoHeaderID
			inner join	dbo.StockItemDetails i 
			on i.PropertyID = h.PropertyID and h.LocationID = i.LocationID and i.StockItemHeaderID=d.StockItemID
			inner join dbo.StockItemHeaders ih
			on ih.Id = i.StockItemHeaderID and ih.CompanyId = i.CompanyID
			inner join dbo.Units u on u.Id=d.UnitID 
		LEFT  JOIN dbo.PoWisePRs AS PWR ON PWR.PoHeaderID = h.Id AND d.StockItemID=PWR.StockItemID
			LEFT  JOIN dbo.RequestHeaders RH ON RH.Id=PWR.RequestHeaderID 

			--inner join  #PENINGPOHEADER on #PENINGPOHEADER.POHeaderID = h.PoHeaderID 
			

		WHERE     (d.PoHeaderID = @PoHeaderIDtemp )

		--SELECT * FROM @tblRequestHeader 

		DECLARE @tblRequestHeaderW AS TABLE (Id INT IDENTITY(1,1),PoDetailID INT,PoHeaderID INT,StockItemID INT,StockItemCode INT,
		ItemName VARCHAR(max),UnitCode int,UnitName VARCHAR(max),RequestedQuantity float ,ApprovedQuantity float ,ReceivedQuantity float,Remarks VARCHAR(max),UnitPrice DECIMAL(18,2),ISMrn BIT, StockInHand  DECIMAL(18,2),AdditonalChargesTotal Decimal(18,3),LastPurchasePrice Decimal(18,3), TotalTax Decimal(18,2) )


		--SELECT * FROM @tblRequestHeader

		WHILE (SELECT count(*) FROM @tblRequestHeader)>0
        BEGIN

		DECLARE @PoHeaderID1 INT,@StockItemID INT 
		SELECT DISTINCT TOP (1)  @PoHeaderID1 = PoHeaderID,@StockItemID=StockItemID, @LocationID =LocationID  FROM @tblRequestHeader

		IF EXISTS(SELECT * FROM @tblRequestHeader WHERE PoHeaderID=@PoHeaderID1 AND StockItemID=@StockItemID AND flag=1)
		BEGIN		
		INSERT INTO @tblRequestHeaderW
		        ( 
		          PoDetailID ,
		          PoHeaderID ,
		          StockItemID ,
		          StockItemCode ,
		          ItemName ,
		          UnitCode ,
		          UnitName ,
		          RequestedQuantity ,
		          ApprovedQuantity ,
		          ReceivedQuantity ,
		          Remarks ,
		          UnitPrice ,
		          ISMrn,
				  StockInHand,
				  AdditonalChargesTotal,
				  LastPurchasePrice,
				  TotalTax
					)
		SELECT  PoDetailID,PoHeaderID,StockItemID,StockItemCode,ItemName,UnitCode,UnitName,SUM(RequestedQuantity),ApprovedQuantity,SUM(ReceivedQuantity),Remarks,UnitPrice,1 ,StockInHand,[dbo].[FN_GetPOwiseAdditionalChargesTotal](@PoHeaderID) , dbo.FN_GetLastGRNPrice(@LocationID,@StockItemID),Tax
		FROM @tblRequestHeader WHERE PoHeaderID=@PoHeaderID1 AND StockItemID=@StockItemID
		GROUP BY PoDetailID,PoHeaderID,StockItemID,StockItemCode,ItemName,UnitCode,UnitName,Remarks,UnitPrice,ApprovedQuantity,StockInHand,Tax

		END 

		ELSE 
		BEGIN
		--select * from @tblRequestHeader

		INSERT INTO @tblRequestHeaderW
		        ( 
		          PoDetailID ,
		          PoHeaderID ,
		          StockItemID ,
		          StockItemCode ,
		          ItemName ,
		          UnitCode ,
		          UnitName ,
		          RequestedQuantity ,
		          ApprovedQuantity ,
		          ReceivedQuantity ,
		          Remarks ,
		          UnitPrice ,
		          ISMrn,
				  StockInHand,
				  AdditonalChargesTotal,
				  LastPurchasePrice,
				  TotalTax
		        )

		SELECT  PoDetailID,PoHeaderID,StockItemID,StockItemCode,ItemName,UnitCode,UnitName,SUM(RequestedQuantity),ApprovedQuantity,SUM(ReceivedQuantity),Remarks,UnitPrice,0 ,StockInHand,[dbo].[FN_GetPOwiseAdditionalChargesTotal](@PoHeaderID) , dbo.FN_GetLastGRNPrice(@LocationID,@StockItemID),Tax
		FROM @tblRequestHeader WHERE PoHeaderID=@PoHeaderID1 AND StockItemID=@StockItemID
		GROUP BY PoDetailID,PoHeaderID,StockItemID,StockItemCode,ItemName,UnitCode,UnitName,Remarks,UnitPrice,ApprovedQuantity,StockInHand,Tax
		END
		DELETE FROM @tblRequestHeader 
	    WHERE  PoHeaderID=@PoHeaderID1 AND StockItemID=@StockItemID 

		END 

		SELECT * FROM @tblRequestHeaderW

		END

END TRY
BEGIN CATCH
	IF @@TRANCOUNT>0
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

