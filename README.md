# homebrew-spring_mt
## dena-redis
### install

```
brew install https://raw.githubusercontent.com/SpringMT/homebrew-spring_mt/master/dena-redis.rb
```

## q4m
### install with MySQL 5.6

```
brew install https://raw.githubusercontent.com/SpringMT/homebrew-spring_mt/master/mysql56-with-q4m.rb
```
### install with MySQL 5.7
```
brew install https://raw.githubusercontent.com/SpringMT/homebrew-spring_mt/master/mysql57-with-q4m.rb
```

### After install

After installation and launching MySQL, please execute below commands.

```bash
mysql -u root -e "$(curl -fsSL https://raw.githubusercontent.com/SpringMT/homebrew-spring_mt/master/q4m_install.sql)"
```

## handlersocket
### install

```
brew install https://raw.githubusercontent.com/SpringMT/homebrew-spring_mt/master/handlersocket.rb
```

### setup
SEE : https://github.com/DeNA/HandlerSocket-Plugin-for-MySQL/blob/master/docs-ja/installation.ja.txt#L57

## cipherscan

```
brew install https://raw.githubusercontent.com/SpringMT/homebrew-spring_mt/master/cipherscan.rb
```
