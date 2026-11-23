
CREATE PROCEDURE InsertPackageMetirials(@XmLdata as xml)
as


declare @DocId int ,
	@Id INT ,
    @RateAnalysisHeaderID INT ,
    @BoqID INT ,
    @SequNo INT ,
    @LocationID INT ,
    @ItemHeaderID INT ,
    @ItemType NVARCHAR(1) ,
    @UnitID INT ,
    @UnitPrice DECIMAL(18, 2) ,
    @Quantity DECIMAL(18, 2) ,
    @ProfitMarginVal DECIMAL(18, 2) ,
    @OverheadCostVal DECIMAL(18, 2) ,
    @isDisRate BIT ,
    @isProjectspecificSubstituteItem BIT ,
    @DisValue DECIMAL(18, 2) ,
    @IPAddress NVARCHAR(MAX) ,
    @CreatedUserID INT ,
    @LastModUserID INT ,
    @CreatedDate DATETIME ,
    @LastModDate DATETIME ,
    @Action [INT] ,
    @ProjectID INT ,
    @DeptID INT ,
    @PropertyID INT ,
    @WorkDetailID INT,
	@Currency INT,
	@ExchangeRate Decimal(18,2)


EXEC sp_xml_preparedocument @DocId  OUTPUT, @XmlData

SELECT   * into #Temdata
FROM      OPENXML (@DocId, '/ROOT/Customer',2)  
           WITH ( Id INT ,
    RateAnalysisHeaderID INT ,
    BoqID INT ,
    SequNo INT ,
    LocationID INT ,
    ItemHeaderID INT ,
    ItemType NVARCHAR(1) ,
    UnitID INT ,
    UnitPrice DECIMAL(18, 2) ,
    Quantity DECIMAL(18, 2) ,
    ProfitMarginVal DECIMAL(18, 2) ,
    OverheadCostVal DECIMAL(18, 2) ,
    isDisRate BIT ,
    isProjectspecificSubstituteItem BIT ,
    DisValue DECIMAL(18, 2) ,
    IPAddress NVARCHAR(MAX) ,
    CreatedUserID INT ,
    LastModUserID INT ,
    CreatedDate DATETIME ,
    LastModDate DATETIME ,
    Action [INT] ,
    ProjectID INT ,
    DeptID INT ,
    PropertyID INT ,
    WorkDetailID INT,
	Currency INT,
	ExchangeRate Decimal(18,2))  




while exists (select top (1) ItemHeaderID  from #temdata)
begin

	select top (1) @Id =@Id,
					@RateAnalysisHeaderID =RateAnalysisHeaderID ,
					@BoqID = BoqID,
					@SequNo = SequNo ,
					@LocationID = LocationID ,
					@ItemHeaderID =ItemHeaderID ,
					@ItemType=ItemType,
					@UnitID = UnitID,
					@UnitPrice =UnitPrice ,
					@Quantity =Quantity ,
					@ProfitMarginVal =ProfitMarginVal ,
					@OverheadCostVal =OverheadCostVal,
					@isDisRate =isDisRate ,
					@isProjectspecificSubstituteItem =isProjectspecificSubstituteItem ,
					@DisValue=DisValue,
					@IPAddress =IPAddress ,
					@CreatedUserID=CreatedUserID,
					@LastModUserID= LastModUserID,
					@CreatedDate = CreatedDate ,
					@LastModDate = LastModDate ,
					@Action =Action ,
					@ProjectID = ProjectID ,
					@DeptID = DeptID,
					@PropertyID = PropertyID ,
					@WorkDetailID = WorkDetailID,
					@Currency = Currency,
					@ExchangeRate = ExchangeRate 
					from #tempdata 

	

	exec [SPP_Save_RateAnalysisDetails] 
		@Id  ,
		@RateAnalysisHeaderID  ,
		@BoqID  ,
		@SequNo  ,
		@LocationID  ,
		@ItemHeaderID  ,
		@ItemType  ,
		@UnitID  ,
		@UnitPrice  ,
		@Quantity ,
		@ProfitMarginVal  ,
		@OverheadCostVal,
		@isDisRate  ,
		@isProjectspecificSubstituteItem  ,
		@DisValue  ,
		@IPAddress,
		@CreatedUserID  ,
		@LastModUserID  ,
		@CreatedDate  ,
		@LastModDate  ,
		@Action ,
		@ProjectID  ,
		@DeptID  ,
		@PropertyID  ,
		@WorkDetailID ,
		@Currency ,
		@ExchangeRate 


	delete from #tmepdata where ItemHeaderID= @ItemHeaderID
end 

EXEC sp_xml_removedocument @docID

GO

