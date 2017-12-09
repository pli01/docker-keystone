image = openstack-keystone
container_name = keystone-server
cmd = 
build:
	docker rmi $(docker images -aq -f dangling=true) || true
	docker build --force-rm -t $(image) -f Dockerfile .
stop:
	docker stop $(container_name) ||true
rm: stop
	docker rm -flv $(container_name) || true

run:
	docker run --name $(container_name) --rm -p 5000:5000 -p 35357:35357 $(image)  $(cmd)

test: prepare-test run-test clean-test
prepare-test: rm
	@echo "Run $(container_name) $(image)"
	docker run -d --name $(container_name) --rm -p 5000:5000 -p 35357:35357 $(image)  $(cmd)
	@echo "Waiting for keystone to become available at http://localhost:5000..." ; \
	success=false ; \
	for i in {1..15}; do  \
        if curl -sSf "http://localhost:5000" > /dev/null; then  \
            echo "Keystone API is up, continuing..." ; \
            success=true ; \
            break ; \
        else  \
            echo "Connection to keystone failed, attempt #$$i of 10" ; \
            sleep 1 ; \
        fi ; \
	done

run-test:
	@echo "Run test"
	docker exec -it $(container_name)  bash -c ' . /root/openrc ; openstack project list '
	@echo "Test ok"

clean-test:
	docker stop $(container_name) ||true
	docker rm -flv $(container_name) || true
