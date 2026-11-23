--Report_ReceipeWiseSales 'S01','07/07/2020','07/07/2020','2'
CREATE  procedure [dbo].[Report_ReceipeWiseSales]
(
	@Outlet char(3),
	@FromDate varchar(10),
	@ToDate varchar(10),
	@PropertyId VARCHAR(2)
)
AS
Declare  @ReceipeSales table
(
	OrderType char(1),
	ReceipeCode varchar(max),
	Seq bigint,
	Receipe varchar(200),
	StockItemCode varchar(16),
	stockItem varchar(200),
	Location varchar(100),
	Unit nvarchar(max),
	Qty DECIMAL(18,2),
	Cost money,
	Category varchar(30),
	NoItemsSolds int ,
	MenuPrice money	,
	Outlet char(3)
)
declare @ReceipeCode char(10)
declare @Category varchar(100)
declare @MenuQty money
declare @MenuPrice money

set dateformat dmy 

declare @FDATE datetime
declare @TDATE datetime


SET @FDATE = convert(varchar(10),@FromDate,103)
SET @TDATE = convert(varchar(10),@ToDate,103)


begin
if object_ID('tempdb..#ReceipeSales') IS NOT NULL drop table #ReceipeSales

insert into @ReceipeSales
	SELECT   RecipeHeader.Ord_Type,  RecipeHeader.RecipeCode, RecipeDetails.Seq, 
	RecipeHeader.Description AS Receipe, StockItemHeaders.StockItemCode, StockItemHeaders.Name AS StockItem, 
			   Locations.Name as Location,-- RecipeDetails.Unit,
			  -- u.Code As Unit ,
			  U.Name AS Unit,
			   RecipeDetails.Qty, RecipeDetails.Cost,'' as Category,0 as NoItemsSolds, 0 as MenuPrice, '' as Outlet
	FROM      RecipeHeader 
			INNER JOIN  RecipeDetails ON RecipeHeader.RecipeCode = RecipeDetails.RecipeCode AND RecipeDetails.PropertyId=RecipeHeader.PropertyId
			--INNER JOIN  StockMaster ON RecipeDetails.StockItemCode = StockMaster.ItemNo AND RecipeDetails.Loc = StockMaster.Location 
			INNER JOIN  StockItemHeaders ON RecipeDetails.StockItemCode = StockItemHeaders.Id  AND RecipeDetails.PropertyId=StockItemHeaders.CompanyId--AND RecipeDetails.Loc = StockItemHeaders.LocationId 
			INNER JOIN  Locations ON RecipeDetails.Loc = Locations.Id AND Locations.CompanyID=RecipeDetails.PropertyId
	        INNER JOIn Units As U ON U.Id=RecipeDetails.Unit --AND U.CompanyId=RecipeDetails.PropertyId
			WHERE 
			  RecipeHeader.PropertyId=@PropertyId            
	                   

----select * from  @ReceipeSales

SELECT     BillTrans.Outlet,Category.Description AS Category, BillTrans.Rate, SUM(BillTrans.Qty) AS MenuQty, ItemBreakDown.RecipeCode
into #tempSales
FROM         BillTrans 
				INNER JOIN
                      Category ON BillTrans.Category = Category.Code  AND Category.PropertyId=@PropertyId
					  INNER JOIN ItemBreakDown ON BillTrans.MainMenuCode = ItemBreakDown.MainMenuCode --AND --BillTrans.sub = ItemBreakDown.SubMenuCode 
					  AND ItemBreakDown.PropertyId=BillTrans.PropertyId
					  INNER JOIN RecipeHeader ON ItemBreakDown.RecipeCode = RecipeHeader.RecipeCode AND RecipeHeader.PropertyId=ItemBreakDown.PropertyId
WHERE     (BillTrans.Outlet =@Outlet  ) AND (BillTrans.OrderDate >= @FDATE) AND (BillTrans.OrderDate <= @TDATE) AND BillTrans.PropertyId=@PropertyId
GROUP BY Category.Description, BillTrans.Rate, ItemBreakDown.RecipeCode, BillTrans.Outlet


select top(1) @ReceipeCode=RecipeCode ,@Category=Category,@MenuQty=MenuQty,@MenuPrice=Rate   from #tempSales 

while @@RowCount >0
begin
	
	print @ReceipeCode
	print @MenuQty
	
	Update @ReceipeSales set  Category =@Category, 
	NoItemsSolds =@MenuQty,
	MenuPrice =@MenuPrice,
	Outlet=@Outlet
	where ReceipeCode=@ReceipeCode
	
	delete from #tempSales where RecipeCode=@ReceipeCode
	select top(1) @ReceipeCode=RecipeCode ,@Category=Category,@MenuQty=MenuQty,@MenuPrice=Rate   from #tempSales 



end


select OrderType ,
	ReceipeCode ,
	Seq,
	Receipe,
	StockItemCode,
	stockItem,
	Location,
	Unit ,
	Qty,
	Cost,
	Category,
	NoItemsSolds  ,
	MenuPrice 	,
	Outlet  from @ReceipeSales order by ReceipeCode

end

GO

