This is the dbt project for the Synthesia Analytics Engineer challenge

# dbt set up instructions
This repository integrates with [dbt](https://docs.getdbt.com/), which creates directed acyclic graphs (DAGs) of data models based on their dependencies, and can be used to build or update these tables from source.

### Installation
Follow install instructions per the [dbt docs](https://docs.getdbt.com/docs/get-started/getting-started-dbt-core):
* Run all the necessary [installs](https://docs.getdbt.com/docs/get-started/homebrew-install) (note that you will need to use [pip](https://docs.getdbt.com/docs/get-started/pip-install) to install the Snowflake adaptor, which this project is built for). Note the section on best practices for installing dbt Core with pip for instructions on how to manage the project with virtual environments

You should now be able to configure your profile.

### Configuring `~/.dbt/profile.yml`
In order to configure your connection to the Snowflake environment, create a new dbt profile set to authenticate to the project via username and password. 

Either add the below template to your existing dbt profile file, or if the file doesn't exist yet, create a blank template as follows:
```zsh
mkdir ~/.dbt
touch ~/.dbt/profiles.yml
```

Template:
```
  synthesia_challenge:
  outputs:
    dev:
      account: <snowflake_account>
      database: analytics
      password: <password>
      role: <your_account_role>
      schema: dev
      threads: 1
      type: snowflake
      user: Synthesia
      warehouse: COMPUTE_WH
  target: dev
```

### Test your connectivity
Now that your profile is configured, you should be able to test your connectivity to Snowflake from the dbt CLI by running a simple dbt model, such as the example model provided:

`pipenv run dbt build -s users`

You should receive a success message if this has completed successfully, and be able to verify that the example view has been created in your Snowflake dataset.

Now you're ready to go - happy modelling!