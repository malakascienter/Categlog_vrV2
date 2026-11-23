
create PROCEDURE SendWhatsAppMessage
    @Number VARCHAR(20),
    @Message NVARCHAR(MAX),
    @Status CHAR(1) OUTPUT,
    @Response NVARCHAR(MAX) OUTPUT
AS
BEGIN
    DECLARE @Object INT;
    DECLARE @hr INT;
    DECLARE @URL VARCHAR(2000);
    DECLARE @Body NVARCHAR(MAX);
    DECLARE @chatId VARCHAR(50);
    DECLARE @json TABLE (Json_Table NVARCHAR(MAX));

    -- Prepare WhatsApp chatId and URL
    SET @chatId = '94' + RIGHT(@Number, LEN(@Number) - 1) + '@c.us';
    SET @URL = 'http://192.168.3.62:3000/send-message';
    SET @Body = '{"type":"text","chatId":"' + @chatId + '","text":"' + @Message + '"}';

    -- Create HTTP object
    EXEC @hr = sp_OACreate 'MSXML2.ServerXMLHTTP.6.0', @Object OUT;
    IF @hr <> 0 EXEC sp_OAGetErrorInfo @Object;

    -- Open POST request
    EXEC @hr = sp_OAMethod @Object, 'open', NULL, 'POST', @URL, 'false';
    IF @hr <> 0 EXEC sp_OAGetErrorInfo @Object;

    -- Set headers
    EXEC sp_OAMethod @Object, 'setRequestHeader', NULL, 'Content-Type', 'application/json';
    EXEC sp_OAMethod @Object, 'setRequestHeader', NULL, 'Accept-Encoding', 'identity';

    -- Send body
    EXEC @hr = sp_OAMethod @Object, 'send', NULL, @Body;
    IF @hr <> 0 EXEC sp_OAGetErrorInfo @Object;

    -- Capture JSON response
    INSERT INTO @json (Json_Table)
    EXEC sp_OAGetProperty @Object, 'responseText';

    select *
    from @json

  DECLARE @JsonData NVARCHAR(MAX);
SELECT TOP 1 @JsonData = Json_Table FROM @json;

SELECT @Status = JSON_VALUE(@JsonData, '$.status') ,   @Response =JSON_VALUE(@JsonData, '$.message')  ;


    -- Cleanup
    EXEC sp_OADestroy @Object;
END

GO

