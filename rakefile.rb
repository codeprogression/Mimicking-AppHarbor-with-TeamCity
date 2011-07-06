require 'rubygems'
require 'erb'
require 'fileutils'
require 'find'
require 'rake'
require 'rake/tasklib'

task :default do
    package_location="sample/"  # website folder location relative to checkout root
    project_file =  "sample/sample.csproj" # website project location relative to checkout root
    package_name = "website"
    package = "website.deploy.cmd"
 
    destination_site = 'Default Web Site/sample' # Change to match IIS path
    clr_version = 'v4.0.30319' 
    framework_dir = File.join(ENV['windir'].dup, 'Microsoft.NET', 'Framework', clr_version)
    msbuild_file = File.join(framework_dir, 'msbuild.exe')

    FileUtils.remove_file("#{package_location}#{package}", true)
    FileUtils.remove_file("#{package_location}#{package_name}.zip", true)
    FileUtils.remove_file("#{package_location}#{package_name}.deploy-readme.txt", true)
    FileUtils.remove_file("#{package_location}#{package_name}.SetParameters.xml", true)
    FileUtils.remove_file("#{package_location}#{package_name}.SourceManifest.xml", true)

    # Package website (requires VS2010 version of msbuild)
    sh "#{msbuild_file} \"#{project_file}\" /maxcpucount /nr:true /v:m /T:Clean,Package /P:BuildInParallel=true;WarningLevel=0;Configuration=debug;DeployIisAppPath=\"#{destination_site}\";PackageLocation=#{package_name}.zip"

    # Deploy website (requires Web Deployment service running on web server)
    sh "#{package_location}#{package} /M:localhost /Y \"-skip:objectName=dirPath,skipAction=Delete,absolutePath=logs\""

end