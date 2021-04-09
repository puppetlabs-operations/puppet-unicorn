puppet-unicorn
==============

This repository has been archived and migrated to [ploperations/ploperations-unicorn](https://github.com/ploperations/ploperations-unicorn)

Install and run unicorn.

Synopsis
--------

    unicorn::app { 'my-sinatra-app':
      approot     => '/opt/my-sinatra-app',
      pidfile     => '/opt/my-sinatra-app/unicorn.pid',
      socket      => '/opt/my-sinatra-app/unicorn.sock',
      user        => 'sinatra',
      group       => 'sinatra',
      preload_app => true,
      rack_env    => 'production',
      source      => 'bundler',
      require     => [
        Class['ruby::dev'],
        Bundler::Install[$app_root],
      ],
    }

Usage
-----

Unicorn applications can either be run using the system unicorn (installed via
gems) or out of bundler. To make this selection, use the `source` parameter for
the defined type.

Requirements
------------

  * Debian something.
