vagrant-oracle18
================

Vagrant + Oracle Linux 7 + Oracle Database 18c (18.3.0) シングル環境の簡易セットアップ。

ダウンロード
------------

Oracle Database 18c (18.3.0)のソフトウェアを入手し、Vagrantfileと同じディレクトリに配置。

環境変数の設定
--------------

`dotenv.sample`というファイルを`.env`という名前のファイルにコピーし、必要に応じて内容を書き換える。

```shell
ORACLE_BASE=/u01/app/oracle
ORACLE_CHARACTERSET=AL32UTF8
ORACLE_EDITION=EE
ORACLE_HOME=/u01/app/oracle/product/18.3.0/dbhome_1
ORACLE_PASSWORD=oracle
ORACLE_PDB=pdb1
ORACLE_SID=orcl
```

セットアップ
------------

`vagrant up`を実行すると、内部的に以下が動く。

* Oracle Linux 7のダウンロードと起動
* Oracle Preinstallation RPMのインストール
* ディレクトリの作成
* 環境変数の設定
* oracleユーザーのパスワード設定
* Oracle Databaseのインストール
* リスナーの作成
* データベースの作成

```console
vagrant up
```

動作確認
--------

ゲストOSに接続する。

```console
vagrant ssh
```

ルートに接続する。

```console
sudo su - oracle
sqlplus system/oracle
SHOW CON_NAME
```

PDBに接続し、サンプル表を確認する。

```console
sqlplus system/oracle@localhost/pdb1
SHOW CON_NAME
SELECT * FROM hr.employees WHERE rownum <= 10;
```

Author
------

[Shinichi Akiyama](https://github.com/shakiyam)

License
-------

[MIT License](https://opensource.org/licenses/MIT)
