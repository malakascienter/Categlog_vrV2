
--EXEC CHECKDATAONTABLES 'L'

CREATE PROC CHECKDATAONTABLES (@ttype char(1))
AS
 

Create table #TempTable (ID int identity(1,1), TableName varchar(200), IDCol VARCHAR(100), RowsCount int, MaxRowID INT, MinRowID INT, Done bit not null default 0)

insert into #TempTable (TableName,IDCol)
select TableName,IDCol from CheckData
where TTYPE=@ttype



declare @SQl NVARCHAR(max) , @id int , @TableName varchar(200), @RowsCount int, @MaxRowID INT, @MinRowID INT, @IDColName VARCHAR(100)

WHILE EXISTS (SELECT ID FROM #TempTable WHERE Done= 0)
begin

	Select top 1 @id= id, @TableName = TableName , @IDColName =IDCol
	FROM #TempTable 
	WHERE Done= 0

	SELECT @RowsCount = 0 , @MaxRowID = 0, @MinRowID = 0

	SET @SQL='SELECT @Count = count(*), @MaxID =MAX('+@IDColName +'), @MinID = MIN('+@IDColName +') FROM '+ @TableName 

	EXEC sp_executesql  @SQL, N'@Count int OUTPUT, @MaxID INT OUTPUT, @MinID INT OUTPUT', @Count=@RowsCount OUTPUT, @MaxID = @MaxRowID OUTPUT, @MinID=@MinRowID OUTPUT


	Update 	#TempTable
	SET RowsCount = @RowsCount,  MaxRowID= @MaxRowID, MinRowID= @MinRowID, done = 1
	WHERE id = @id



end 

select * from #TempTable

GO

