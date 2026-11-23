
CREATE PROCEDURE [dbo].[USP_GetAllEvents]
    @PropertyId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        eh.[EventNo],
        eh.[EventName],
        FORMAT(ed.[Date], 'dd/MM/yyyy') as EventDate,
        eh.[OutletCode],
        1 [IsActive],
        eh.[IsEventAvailable]
    FROM [dbo].[EventHeader] eh
    LEFT JOIN [dbo].[EventDateDetails] ed ON eh.[ID] = ed.[EventID]
    WHERE eh.[PropertyId] = @PropertyId
    AND ed.[Date] = (SELECT MAX([Date]) FROM [dbo].[EventDateDetails] WHERE [EventID] = eh.[ID])
    ORDER BY ed.[Date] DESC, eh.[EventNo] DESC;
END

GO

