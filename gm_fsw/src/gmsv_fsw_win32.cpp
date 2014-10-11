#include "..\include\GarrysMod\Lua\Interface.h"
#include <stdio.h>
#include <windows.h>
#include <string>
#include <iostream>
#using <system.dll>
#include <msclr/marshal.h>
#include <msclr/marshal_cppstd.h>

using namespace std;;
using namespace GarrysMod::Lua;
using namespace System;
using namespace System::IO;

string changedFile = "";
string changedType = "";
bool didChangeFile = false;

string ExePath() {
    char buffer[MAX_PATH];
    GetModuleFileName( NULL, buffer, MAX_PATH );
    string::size_type pos = string( buffer ).find_last_of( "\\/" );
    return string( buffer ).substr( 0, pos).append("\\garrysmod");
}

int GetDirectory( lua_State* state )
{
	string directory = ExePath();
	LUA->PushString( directory.c_str() );
	return 1;
}

public ref class FSEventHandler
{
public:
    void OnChanged (Object^ source, FileSystemEventArgs^ e)
    {
		changedType = "Changed";
		if (e->ChangeType.ToString() == "Created") {
			changedType = "Created"; // Push our argument
		}
		else if (e->ChangeType.ToString() == "Deleted") {
			changedType = "Deleted"; // Push our argument
		}
		else if (e->ChangeType.ToString() == "Renamed") {
			changedType = "Renamed"; // Push our argument
		}

		changedFile = msclr::interop::marshal_as< string >(e->FullPath);
		didChangeFile = true;
    }
    void OnRenamed(Object^ source, RenamedEventArgs^ e)
    {

    }
};

public ref class FSWatcher
{
public:
	static FileSystemWatcher^ fsWatcher;
	FSWatcher(String^ path)
	{
		fsWatcher = gcnew FileSystemWatcher( );
		fsWatcher->Path = path;
		fsWatcher->IncludeSubdirectories = true;
		fsWatcher->NotifyFilter = static_cast<NotifyFilters> 
				  (NotifyFilters::FileName | 
				   NotifyFilters::Attributes | 
				   NotifyFilters::LastAccess | 
				   NotifyFilters::LastWrite | 
				   NotifyFilters::Security | 
				   NotifyFilters::Size );

		FSEventHandler^ handler = gcnew FSEventHandler(); 
		fsWatcher->Changed += gcnew FileSystemEventHandler( 
				handler, &FSEventHandler::OnChanged);
		fsWatcher->Created += gcnew FileSystemEventHandler( 
				handler, &FSEventHandler::OnChanged);
		fsWatcher->Deleted += gcnew FileSystemEventHandler( 
				handler, &FSEventHandler::OnChanged);
		fsWatcher->Renamed += gcnew RenamedEventHandler( 
				handler, &FSEventHandler::OnRenamed);

		fsWatcher->EnableRaisingEvents = true;
	}
};

int FSWPollChanged( lua_State* state )
{
	if (didChangeFile) {
		LUA->PushString( changedFile.c_str() );
		LUA->PushString( changedType.c_str() );
		didChangeFile = false;

		return 2;
	}
	else {
		LUA->PushNil();
		return 1;
	}
}

//
// Called when you module is opened
//
GMOD_MODULE_OPEN()
{
	//globalState = state;

	LUA->PushSpecial( GarrysMod::Lua::SPECIAL_GLOB );	// Push global table
	LUA->PushString( "FSWGetDirectory" );					// Push Name
	LUA->PushCFunction( GetDirectory );			// Push function
	LUA->SetTable( -3 );								// Set the table 		

	LUA->PushString( "FSWPollChanged" );					// Push Name
	LUA->PushCFunction( FSWPollChanged );			// Push function
	LUA->SetTable( -3 );								// Set the table 

	string directory = ExePath();
	gcnew FSWatcher(gcnew String(directory.c_str()));

	LUA->PushSpecial(GarrysMod::Lua::SPECIAL_GLOB);
	LUA->GetField(-1, "RunString");
		LUA->PushString("hook.Add(\"Tick\",\"FSWPollChanged\",function()\
						local file, type = FSWPollChanged()\
						if file then\
						hook.Run(\"FSWOn\"..type,file)\
						end\
						end)");
		LUA->Call(1, 0);
	LUA->Pop();

	return 0;
}

//
// Called when your module is closed
//
GMOD_MODULE_CLOSE()
{
	delete (FSWatcher::fsWatcher);
	return 0;
}