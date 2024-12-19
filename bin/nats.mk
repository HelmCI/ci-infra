
nats-kubectl = kubectl -n infra
nats-box	 = $(shell $(nats-kubectl) get pod -l app=nats-box -o name)
nats-exec	 = $(nats-kubectl) exec $(nats-box)
nats-cmd	 = $(nats-exec) -- nats
nats-docs:
	$(nats-cmd)
nats-version:
	$(nats-cmd) --version
nats-cheat:
	$(nats-cmd) cheat
nats-sh:
	$(nats-exec) -it -- sh
# https://docs.nats.io/nats-concepts/core-nats/pubsub/pubsub_walkthrough
nats-sub:
	$(nats-cmd) sub msg.test
nats-pub:
	$(nats-cmd) pub msg.test nats-message-1
