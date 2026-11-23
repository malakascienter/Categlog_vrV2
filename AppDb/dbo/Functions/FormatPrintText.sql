
CREATE FUNCTION  [dbo].[FormatPrintText](@linetypeid int ,@col int , @data varchar(max))
returns varchar(max)
as begin

    declare @Alignment char(1), @length int, @leftPadding int , @rightPadding int  


    set @data= rtrim((@data))

    select @Alignment= Alignment,@length =length   from LineWiseColums
    where linetypeid=@linetypeid and ColumnNumber= @col

    if @Alignment='C'
    begin
        set @leftPadding =( @length - len(@data))/2
    end 
    else if @Alignment='L'
    begin
        set @leftPadding = 0
    end 
    else
    begin
        set @leftPadding = @length - len(@data)
    end 

    set @rightPadding = @length - len(@data)- @leftPadding

	 
    return replicate(' ', @leftPadding)+ @data+ replicate(' ', @rightPadding)
end

GO

