
CREATE Procedure [dbo].[SP_POPreperation]
( 
	@PropertyID int,
	@SelectedLocationID int
)

as

Declare @ApprovelCount int
Declare @TransactionHeaderID int
Declare @rCount int

Declare @RequestHeaderID int, @LocationID int, @DocumentNo varchar(50), @RequestDate datetime
Declare @HRemarks varchar(500), @DepartmentID int, @DepartmentName varchar(200), @StockItemID int
Declare @ItemName varchar(200), @StockItemCode varchar(50),@LocationName varchar(200)
Declare @UnitID int, @UnitName varchar(200), @ApprovedQuantity money
Declare @ItemRemarks varchar(200), @RequestedQuantity money
Declare @SupplierPurchaseUnitID int,@Supplier varchar(200),@CostPrice money,@SupplierID int

Declare @Temp table 
(
	RequestHeaderID int, LocationID int, DocumentNo varchar(50), RequestDate datetime, 
	HRemarks varchar(500), DepartmentID int, DepartmentName varchar(200), StockItemID int,
	ItemName varchar(200), StockItemCode varchar(50),UnitID int, UnitName varchar(200), 
	ApprovedQuantity money,ItemRemarks varchar(200), RequestedQuantity money,
	SupplierPurchaseUnitID int,Supplier varchar(200),CostPrice money,SupplierID int,LocationName varchar(200)
)
 

BEGIN TRY

	begin tran
		print ('Awa 1')
		set @ApprovelCount=0

		SELECT     @ApprovelCount=COUNT(a.TransactionApprovalID) FROM 
		TransactionWiseApprovalTypes AS a 
		INNER JOIN TransactionTypes 
		AS b ON a.TransactionID = b.Id 
		WHERE (b.Code = 'RP') and PropertyID=@PropertyID  and a.LocationId = @SelectedLocationID-- add location

		--exec SP_POPreperation 3,49
		SELECT     a.TransactionHeaderID, COUNT(*) AS rCount  into #table
		FROM         ApprovalLogs AS a INNER JOIN
						  RequestHeaders AS b ON a.TransactionHeaderID = b.Id
		WHERE     (b.RequestType = 'RP') AND (b.DocumentStatus = 'P') AND (a.IsComplete = 1)  and a.PropertyID =@PropertyID   and a.LocationID = @SelectedLocationID
		GROUP BY a.TransactionHeaderID 
		HAVING      (COUNT(*) >= @ApprovelCount) 
		
		print('point 1')					

		select @TransactionHeaderID=TransactionHeaderID,@rCount=rCount from #table
		
		while  @@rowcount>0
		begin
			
		Select  a.Id, a.LocationID, a.RequestType, a.DocumentNo, a.RequestDate, a.DocumentStatus, a.Remarks, a.DepartmentID, d.Name,b.StockItemID,
				s.Name As ItemName, s.StockItemCode, b.UnitID, u.Name As UnitName, b.ApprovedQuantity, b.Remarks As DetailsRemarks, b.RequestedQuantity,
				Locations.Name As LocationName
		INTO              [#t]
		FROM            RequestHeaders AS a INNER JOIN
								 RequestDetails AS b ON a.Id = b.RequestHeaderID INNER JOIN
								 StockItemHeaders AS s ON b.StockItemID = s.Id INNER JOIN
								 Units AS u ON b.UnitID = u.Id INNER JOIN
								 Departments AS d ON a.DepartmentID = d.id AND a.RequestType = 'RP' 
								 AND a.DocumentStatus = 'P' AND a.IsApproved = 1 
								 INNER JOIN
								 Locations ON a.LocationID = Locations.Id
		where a.PropertyID=@PropertyID and a.id = @TransactionHeaderID-- and a.LocationID = @SelectedLocationID 

		--select *  from [#t]


				select  @RequestHeaderID=Id, @LocationID=LocationID, @DocumentNo=DocumentNo, @RequestDate=RequestDate,
				@HRemarks=Remarks, @DepartmentID=DepartmentID, @DepartmentName=Name,
				@StockItemID=StockItemID,@ItemName=ItemName, @StockItemCode=StockItemCode, @UnitID=UnitID,
				@UnitName=UnitName, @ApprovedQuantity=ApprovedQuantity,@ItemRemarks=Remarks, @RequestedQuantity =RequestedQuantity, @LocationName=LocationName  from #t
				
				
				
				--exec SP_POPreperation 2, 50 
	
    
				print('point 1')					
					  
				while @@Rowcount>0
				print('point 2')
				begin
				
				---select * from Suppliers
					--select * from SupplierMasterDetails -nned to create
				
					SELECT  TOP(1) @SupplierID=SupplierWiseItemDetails.SupplierID, @CostPrice=min(SupplierWiseItemDetails.CostPrice) ,
					 @SupplierPurchaseUnitID=SupplierWiseItemDetails.PurchaseUnitID, @Supplier=Suppliers.Name 
					FROM SupplierWiseItemDetails INNER JOIN Suppliers ON SupplierWiseItemDetails.SupplierID = Suppliers.ID
					where SupplierWiseItemDetails.StockItemID =@StockItemID and Suppliers.PropertyID = @PropertyID AND SupplierWiseItemDetails.IsDefaultSupplier = 1
					group by SupplierWiseItemDetails.CostPrice, SupplierWiseItemDetails.PurchaseUnitID, Suppliers.Name ,SupplierWiseItemDetails.SupplierID
					
									
					--SELECT  Top(1) @SupplierID=SupplierWiseItemDetails.SupplierID, @CostPrice=min(SupplierWiseItemDetails.CostPrice) ,
					-- @SupplierPurchaseUnitID=SupplierWiseItemDetails.PurchaseUnitID, @Supplier=Suppliers.Name 
					--FROM SupplierWiseItemDetails INNER JOIN Suppliers ON SupplierWiseItemDetails.SupplierID = Suppliers.ID
					--WHERE SupplierWiseItemDetails.StockItemID =StockItemID And SupplierWiseItemDetails.CompanyId=PropertyID
					--group by SupplierWiseItemDetails.CostPrice, SupplierWiseItemDetails.PurchaseUnitID, Suppliers.Name ,SupplierWiseItemDetails.SupplierID
					--ORDER BY CostPrice ASC

					insert into @Temp
					(RequestHeaderID , LocationID , DocumentNo , RequestDate,HRemarks, DepartmentID 
					 , DepartmentName , StockItemID, ItemName , StockItemCode ,UnitID , UnitName 
					 ,ApprovedQuantity,ItemRemarks, RequestedQuantity ,SupplierPurchaseUnitID 
					 ,Supplier ,CostPrice,SupplierID,LocationName)
					values
					(
					@RequestHeaderID , @LocationID , @DocumentNo , @RequestDate,@HRemarks, @DepartmentID 
					 , @DepartmentName , @StockItemID, @ItemName , @StockItemCode ,@UnitID , @UnitName 
					 ,@ApprovedQuantity,@ItemRemarks, @RequestedQuantity ,@SupplierPurchaseUnitID 
					 ,@Supplier ,isnull(@CostPrice,0),@SupplierID,@LocationName)
		                  
				
					delete from  #t where StockItemID=@StockItemID and LocationID=@LocationID and DepartmentID=@DepartmentID
					
					select  @RequestHeaderID=Id, @LocationID=LocationID, @DocumentNo=DocumentNo, @RequestDate=RequestDate,
					 @HRemarks=Remarks, @DepartmentID=DepartmentID, @DepartmentName=Name,
					@StockItemID=StockItemID,@ItemName=ItemName, @StockItemCode=StockItemCode, @UnitID=UnitID,
					@UnitName=UnitName, @ApprovedQuantity=ApprovedQuantity,@ItemRemarks=Remarks, @RequestedQuantity =RequestedQuantity,@LocationName=LocationName from #t
					
					
			   end
			
			
			drop table #t
			
			delete from #Table where  TransactionHeaderID=@TransactionHeaderID
			select @TransactionHeaderID=TransactionHeaderID,@rCount=rCount from #table
		end

		drop table #Table

		--select * into temp_potemp  from @Temp
		select * from @Temp

		commit tran
END TRY
BEGIN CATCH
		
		
		rollback tran
		return @@error 
        --INSERT INTO GEN_ErrTable (ErrorNumber,ErrorSeverity,ErrorState,ErrorProcedure,ErrorLine,ErrorMessage)
        --VALUES (ERROR_NUMBER(),ERROR_SEVERITY(),ERROR_STATE(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE())

END CATCH;

GO

