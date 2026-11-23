/*  Honour an unsubscribe link.

    Reached from an ANONYMOUS endpoint - the whole point of an unsubscribe link
    is that it works without signing in, and requiring a login to stop receiving
    mail is the pattern regulators object to.

    Takes the hash of the token, never the token: the API hashes what arrives in
    the URL before calling this. An unknown hash returns Found = 0 rather than
    throwing, so a prober cannot tell a wrong guess from a valid link by the
    shape of the response.                                                       */
CREATE PROCEDURE dbo.LTYM_Unsubscribe_Redeem
    @TokenHash varchar(200)
AS
BEGIN
    SET NOCOUNT ON;

    EXEC dbo.LTYC_Unsubscribe_Redeem @TokenHash = @TokenHash;
END

GO

