--SP_SelectPendingJobApproval 1,1,1
CREATE PROCEDURE [dbo].[SP_SelectPendingJobApproval] 
	--@Type				VARCHAR(2) = 'S',
	@UserProfileId				int = 1,
	@PropertyID			INT = 0,
	@DepID INT
	--@JobHeaderID			VARCHAR(100) = NULL
	--@PoDetailID			VARCHAR(100) = NULL
AS
BEGIN
Declare @T1 varchar(max),
			@T2 varchar(max),
			@T3 varchar(max),
			@Sql varchar(max)
						
			IF OBJECT_ID('tempdb..#PENINGJOBHEADER') IS NOT NULL
			DROP TABLE #PENINGJOBHEADER

			create table #PENINGJOBHEADER (JobHeaderID int ,ApprovalTypeID int,ReqUserProfId int, ReqUserProf varchar(max),--POValue DECIMAL(18,2),
			 TransactionID INT)

			insert into #PENINGJOBHEADER 
			EXEC [dbo].[SP_SelectPeningJOBApprovalForUser]  @UserProfileId, @PropertyID

			 



			--IF(@Type = 'S')
			--BEGIN
			SELECT     
			h.ID SN,
			JobCardNumber, 
			PD.ProjectName, 
			BH.BOQName,
			app.Id AS ApprovalTypeID,
			app.ApprovalTypeName [Approvel], 
			l.Name Location,
			#PENINGJOBHEADER.ReqUserProfId,
			#PENINGJOBHEADER.ReqUserProf,
			--#PENINGJOBHEADER.POValue,
			
			JobCreateDate,
			
			--s.Name Supplier, 
			--h.Remarks,
			#PENINGJOBHEADER.TransactionID
		FROM         dbo.JobHeaders h
		INNER JOIN ProjectDetails PD ON  h.ProjectID=PD.Id 
		INNER JOIN Customers CS ON PD.ClientID=CS.Id 
		INNER JOIN Companies CO ON CS.CompanyId=CO.CompanyID
		INNER JOIN BOQHeaders BH ON h.BOQID=BH.Id
		inner join  #PENINGJOBHEADER on #PENINGJOBHEADER.JobHeaderID = h.ID
		inner join dbo.Locations l on l.Id=CS.LocationId
		--inner join dbo.Suppliers s on h.SupplierID=s.ID 
		inner join dbo.ApprovalTypes app
		on app.Id= #PENINGJOBHEADER.ApprovalTypeID
		WHERE     (CS.CompanyId = @PropertyID) and h.Approved=0 and Complete = 0 and Status <> 'X' and h.DepartmentID=@DepID
		ORDER BY JobCreateDate DESC 
		--AND h.Id = case when @PoHeaderID IS null then h.Id  else @PoHeaderID end 
		
		END

	
		
		--DELETE FROM @tblRequestHeader 
	 --   WHERE  PoHeaderID=@PoHeaderID1 AND StockItemID=@StockItemID 

		--END 

		--SELECT * FROM @tblRequestHeaderW

		--END

		--END

GO

