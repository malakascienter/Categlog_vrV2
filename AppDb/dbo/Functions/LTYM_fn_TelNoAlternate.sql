
CREATE   FUNCTION [dbo].[LTYM_fn_TelNoAlternate] (@TelNo VARCHAR(15))
RETURNS VARCHAR(15)
AS
BEGIN
    RETURN CASE
               WHEN @TelNo IS NULL THEN NULL
               WHEN LEN(@TelNo) > 9 AND LEFT(@TelNo, 1) = '0' THEN SUBSTRING(@TelNo, 2, LEN(@TelNo))
               WHEN LEN(@TelNo) = 9 THEN CONCAT('0', @TelNo)
               ELSE NULL
           END;
END

GO

