# homebrew-spring_mt
## dena-redis
### install

## q4m
### install

```
brew install https://raw.githubusercontent.com/SpringMT/homebrew-spring_mt/master/mysql56-with-q4m.rb
brew install mysql56-with-q4m
```
### After install

Please execute below SQL statements.

```sql
INSTALL PLUGIN queue SONAME 'libqueue_engine.so';
CREATE FUNCTION queue_wait RETURNS INT SONAME 'libqueue_engine.so';
CREATE FUNCTION queue_end RETURNS INT SONAME 'libqueue_engine.so';
CREATE FUNCTION queue_abort RETURNS INT SONAME 'libqueue_engine.so';
CREATE FUNCTION queue_rowid RETURNS INT SONAME 'libqueue_engine.so';
CREATE FUNCTION queue_set_srcid RETURNS INT SONAME 'libqueue_engine.so';
CREATE FUNCTION queue_compact RETURNS INT SONAME 'libqueue_engine.so';
CREATE FUNCTION queue_stats RETURNS STRING SONAME 'libqueue_engine.so'; 
```

