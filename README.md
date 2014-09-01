# homebrew-spring_mt
## dena-redis
### install

```
brew install https://raw.githubusercontent.com/SpringMT/homebrew-spring_mt/master/dena-redis.rb
brew install dena-redis
```

## q4m
### install

```
brew install https://raw.githubusercontent.com/SpringMT/homebrew-spring_mt/master/mysql56-with-q4m.rb
brew install mysql56-with-q4m
```
### After install

After installation and launching MySQL, please execute below commands.

```bash
mysql -u root -e "$(curl -fsSL https://raw.githubusercontent.com/SpringMT/homebrew-spring_mt/master/q4m_install.sql)"
```


