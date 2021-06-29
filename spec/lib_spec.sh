Describe 'lib'
  Include lib/lib.sh

  Context 'setup functions:'
    Describe 'setup'
      setup_mac() { echo 'setup mac'; }
      setup_linux() { echo 'setup linux'; }
      write_configs() { echo 'wrote configs'; }

      It 'informs the user of the start and finish'
        uname() { echo 'Darwin'; }
        When call setup
        The line 1 should equal '**********'
        The line 2 should equal 'yamss setup initiated'
        The line 3 should equal '**********'
        The line 7 should equal '**********'
        The line 8 should equal 'yamss setup completed'
        The line 9 should equal '**********'
      End

      It 'calls setup_mac and write_configs when on mac'
        uname() { echo 'Darwin'; }
        When call setup
        The line 4 should equal 'MacOS detected. Running local MacOS setup.'
        The line 5 should equal 'setup mac'
        The line 6 should equal 'wrote configs'
      End

      It 'calls setup_linux and write_configs when on linux'
        uname() { echo 'Linux'; }
        When call setup
        The line 4 should equal 'Linux detected. Running remote Linux setup.'
        The line 5 should equal 'setup linux'
        The line 6 should equal 'wrote configs'
      End
    End
  End

  Context 'tool functions:'
    Describe 'set_tool_functions'
      It 'generates the four function names of a given tool'
        When call set_tool_functions tul
        local expected_value=(tul__prepare tul__setup tul__augment tul__bootstrap)
        The variable tool_functions should equal "$expected_value" 
      End
    End

    Describe 'exec_tool_functions'
      It 'executes the functions in tool_functions'
        blah() { echo 'blah'; }
        yah() { echo 'yah'; }
        tool_functions=(blah yah)
        When call exec_tool_functions
        The line 1 of output should equal 'blah'
        The line 2 of output should equal 'yah' 
      End
    End

    Describe 'set_remote_tool_url'
      It 'sets the remote_tool_url'
        When call set_remote_tool_url tul
        The variable remote_tool_url should equal "https://raw.githubusercontent.com/aegatlin/setup/master/lib/tools/tul.sh"
      End
    End

    Describe 'create_tool_file'
      It 'creates a temporary tool file and adds it to TEMP_FILES'
        When call create_tool_file tul
        The path 'tul.temp.sh' should be file
        The variable current_tool_file should equal 'tul.temp.sh'
        The variable TEMP_FILES should include 'tul.temp.sh'
      End
    End

    Describe 'load_tool'
      It 'calls create_tool_file and write_and_source_tool_file'
        create_tool_file() { echo "test $1"; }
        write_and_source_tool_file() { echo 'test2'; }
        When call load_tool tul
        The line 1 should equal 'test tul'
        The line 2 should equal 'test2'
      End
    End

    Describe 'load_tools'
      It 'calls load_tool on a list of tools' 
        load_tool() { echo $1; }
        exec_tool_functions() { :; } # fancy noop
        local mac_tools=(zsh git brew direnv tmux vim asdf)
        local expected_tool_functions=('asdf__prepare' 'asdf__setup' 'asdf__augment' 'asdf__bootstrap')
        When call load_tools ${mac_tools[@]}
        The line 1 should equal 'zsh'
        The line 2 should equal 'git'
        The line 3 should equal 'brew'
        The line 4 should equal 'direnv'
        The line 5 should equal 'tmux'
        The line 6 should equal 'vim'
        The line 7 should equal 'asdf'
        The variable remote_tool_url should equal 'https://raw.githubusercontent.com/aegatlin/setup/master/lib/tools/asdf.sh'
        The variable tool_functions should equal "$expected_tool_functions"
      End
    End
  End

  Context 'helper functions:'
    Describe 'error_and_exit'
      It 'formats any one-line error message'
        When run error_and_exit "oops"
        The line 1 of output should equal ""
        The line 2 of output should equal "**********"
        The line 3 of output should equal "ERROR"
        The line 4 of output should equal "Error message: oops"
        The line 5 of output should equal ""
        The line 6 of output should equal "Running clean up and exiting"
        The line 7 of output should equal "**********"
        The status should be failure
      End
    End

    Describe 'clean_up'
      before_each() {
        touch tul.temp.sh
        touch tuul.temp.sh
        TEMP_FILES=(tul.temp.sh tuul.temp.sh)
        var1='wow'
        var2=3
        UNSET_LIST=(var1 var2 TEMP_FILES)
      }

      BeforeEach 'before_each'

      It 'unsets all variables in UNSET_LIST'
        When call clean_up
        The variable var1 should be undefined
        The variable var2 should be undefined
        The variable UNSET_LIST should be undefined
      End 
      
      It 'removes temporary files stored in TEMP_FILES'
        When call clean_up
        The path 'tul.temp.sh' should not be file
        The path 'tuul.temp.sh' should not be file
        The variable TEMP_FILES should not be defined
      End
    End

    Describe 'has_command'
      It 'returns 0 (success) when command is present on machine'
        When call has_command echo
        The status should be success
      End

      It 'returns 1 (failure) when the command is not present on the machine'
       When call has_command echp
       The status should be failure
      End
    End

    Describe 'ensure_command'
      It 'returns 0 (success) when command is present on machine'
        When call ensure_command echo
        The status should be success
      End

      It 'displays error message and exits when command is not present on machine'
        error_and_exit() { echo "no bueno: $1"; exit 1; }
        When run ensure_command echp
        The line 1 should equal "no bueno: Command not found: echp"
        The status should be failure
      End
    End

    Describe 'run_command'
      It 'echos the command before evaluating it'
        When call run_command "echo 'hello'"
        The line 1 should equal "echo 'hello'"
        The line 2 should equal 'hello'
      End
    End
  End
End