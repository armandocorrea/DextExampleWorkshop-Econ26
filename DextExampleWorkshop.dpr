program DextExampleWorkshop;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  Dext.Utils,
  Dext.Web.Interfaces,
  Dext.WebHost,
  Dext.Web;

var
  Builder: IWebHostBuilder;
  Host: IWebHost;

function GetEnvironmentValue(const AName: string; const ADefault: string = ''): string;
begin
  Result := GetEnvironmentVariable(AName);

  if Result = '' then
    Result := ADefault;
end;

begin
  try
    var LVersion := GetEnvironmentValue('APP_VERSION', 'development');
    var LCommit := GetEnvironmentValue('APP_COMMIT', 'unknown');
    var LBuildDate := GetEnvironmentValue('APP_BUILD_DATE', 'unknown');

    SetConsoleCharSet(65001);
    WriteLn('🚀 Dext Minimal API Example');
    Writeln('========================================');
    Writeln('Version....: ' + LVersion);
    Writeln('Commit.....: ' + LCommit);
    Writeln('Build Date.: ' + LBuildDate);
    Writeln('========================================');
    WriteLn;

    Builder := TDextWebHost.CreateDefaultBuilder;
    Builder.UseUrls('http://localhost:8080');

    Builder.Configure(
      procedure(App: IApplicationBuilder)
      begin
        App.UseMiddleware(TRequestLoggingMiddleware);
        TApplicationBuilderStaticFilesExtensions.UseStaticFiles(App);

        // GET / - Uses DI to resolve service
        App.MapGet('/',
          procedure(Context: IHttpContext)
          begin
            Context.Response.StatusCode := 200;
            Context.Response.ContentType := 'text/html; charset=utf-8';
            //#2196F3 - Azul
            //#FF0000 - Vermelho
            Context.Response.Write(
              '<!DOCTYPE html>' +
              '<html>' +
              '<head>' +
              '  <title>Página Azul</title>' +
              '</head>' +
              '<body style="margin:0; background:#2196F3; min-height:100vh;">' +
              '  <h1 style="color:white; text-align:center; padding-top:100px;">' +
              '    Aplicação construída utilizando o Dext Framework <br/>' +
              '    Página Azul' +
              '  </h1>' +
              '</body>' +
              '</html>'
            );
         end);

        // GET /health - Health check endpoint
        App.MapGet('/health',
          procedure(Context: IHttpContext)
          begin
            Context.Response.Json('{"status": "healthy"}');
          end);

        WriteLn;
        WriteLn('📍 Routes registered:');
        WriteLn('  GET /              - JSON response');
        WriteLn('  GET /health        - Health check');
        WriteLn;
        WriteLn('═══════════════════════════════════════════');
        WriteLn('🌐 Server running on http://localhost:8080');
        WriteLn('═══════════════════════════════════════════');
        WriteLn;
        WriteLn('Press Enter to stop the server...');
      end);

    Host := Builder.Build;
    Host.Run;

    ConsolePause;
    Host.Stop;
  except
    on E: Exception do
      WriteLn('❌ Error: ', E.Message);
  end;
end.
